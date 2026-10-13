"""Shared helpers: tiny YAML-subset loader (PyYAML used if installed) and pluggable command runner."""
import json, os, re, shlex, subprocess

def _scalar(v):
    v = v.strip()
    if v == "" : return None
    if v[0] == '"' and v[-1] == '"': return json.loads(v)
    if v[0] == "'" and v[-1] == "'": return v[1:-1].replace("''", "'")
    if v.startswith("[") and v.endswith("]"):
        try: return json.loads(v)
        except Exception: return [_scalar(x) for x in v[1:-1].split(",") if x.strip()]
    if v in ("true", "false"): return v == "true"
    if v in ("null", "~"): return None
    if re.fullmatch(r"-?\d+", v): return int(v)
    return v

def _mini_yaml(text):
    """Supports what the templates use: nested maps, lists of scalars/maps, '|' and '>' block strings, # comments."""
    lines = [l.rstrip("\n") for l in text.splitlines()]
    def strip_comment(l):
        if l.lstrip().startswith("#"): return ""
        return re.sub(r"\s+#\s.*$", "", l) if not re.search(r"""['"][^'"]*\s#\s""", l) else l
    toks = []
    i = 0
    while i < len(lines):
        raw = lines[i]; l = strip_comment(raw)
        if not l.strip(): i += 1; continue
        toks.append((len(l) - len(l.lstrip()), l.strip(), i)); i += 1
    pos = [0]
    def block(ind, start_line, fold):
        out = []; j = start_line + 1
        bi = None
        while j < len(lines):
            l = lines[j]
            if l.strip() == "": out.append(""); j += 1; continue
            li = len(l) - len(l.lstrip())
            if li <= ind: break
            bi = li if bi is None else bi
            out.append(l[bi:]); j += 1
        while pos[0] < len(toks) and toks[pos[0]][2] < j: pos[0] += 1
        s = "\n".join(out).rstrip("\n") + "\n"
        return " ".join(x for x in s.split("\n") if x) + "\n" if fold else s
    def parse(ind):
        if pos[0] >= len(toks): return None
        if toks[pos[0]][1].startswith("- "): return parse_list(toks[pos[0]][0])
        return parse_map(toks[pos[0]][0])
    def value(key_ind, rest, line):
        if rest in ("|", "|-", ">", ">-"): return block(key_ind, line, rest[0] == ">")
        if rest == "":
            if pos[0] < len(toks) and (toks[pos[0]][0] > key_ind or (toks[pos[0]][0] == key_ind and toks[pos[0]][1].startswith("- "))):
                return parse(toks[pos[0]][0])
            return None
        return _scalar(rest)
    def parse_map(ind):
        d = {}
        while pos[0] < len(toks) and toks[pos[0]][0] == ind and not toks[pos[0]][1].startswith("- "):
            _, t, line = toks[pos[0]]; pos[0] += 1
            k, _, rest = t.partition(":")
            d[k.strip().strip("\"'")] = value(ind, rest.strip(), line)
        return d
    def parse_list(ind):
        out = []
        while pos[0] < len(toks) and toks[pos[0]][0] == ind and toks[pos[0]][1].startswith("- "):
            _, t, line = toks[pos[0]]; item = t[2:].strip()
            if re.match(r"^[\w\-]+:(\s|$)", item):
                # map item: rewrite token as a map entry at deeper indent
                toks[pos[0]] = (ind + 2, item, line)
                out.append(parse_map(ind + 2))
            else:
                pos[0] += 1; out.append(_scalar(item))
        return out
    return parse(0)

def load_spec(path):
    text = open(path).read()
    if path.endswith(".json"): return json.loads(text)
    try:
        import yaml  # type: ignore
        return yaml.safe_load(text)
    except ImportError:
        return _mini_yaml(text)

def run_cmd(env_var, default, stdin_text, timeout=300):
    """Run the pluggable command named by env_var (shell-split), prompt on stdin, answer on stdout."""
    cmd = os.environ.get(env_var) or default
    for _ in range(2):
        r = subprocess.run(shlex.split(cmd), input=stdin_text, capture_output=True, text=True, timeout=timeout)
        if r.returncode == 0 and r.stdout.strip(): return r.stdout.strip(), cmd
    raise RuntimeError(f"{env_var} ({cmd}) exit {r.returncode}: {r.stderr[-300:]}")

def parse_verdict(s):
    m = re.search(r"\{.*\}", s, re.S)
    d = json.loads(m.group(0) if m else s)
    if "verdict" not in d: raise ValueError("judge output has no 'verdict'")
    d["verdict"] = str(d["verdict"]).upper()
    d.setdefault("violated_must_not", []); d.setdefault("reason", "")
    return d
