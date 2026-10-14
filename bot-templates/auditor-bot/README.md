# auditor-bot template

After every ship lands, the auditor proves it again from the evidence. A FAIL creates `<gate-dir>/<lane>.paused`, and `ship-log` then refuses that lane until the fix passes a re-audit and `gate-clear` runs. The auditor also spot-checks review-loop logs.

| File | What it is |
|---|---|
| `profile.md` | bot instructions |
| `skills/audit-a-ship`, `skills/getting-started` | the audit checklist and first-run setup |
| `scripts/ship-log` | the gate lanes call before a push, merge or deploy |
| `scripts/audit-row` | deterministic part of an audit; writes one JSON verdict row |
| `scripts/seed-canary` | appends a known-bad row so you can check the auditor catches it |
| `scripts/review-loop` | pre-merge reviewer from a different model family, max 3 rounds |
| `scripts/ui-proof` | recorded Playwright proof tied to the head SHA |
| `scripts/gate-clear` | the only sanctioned way to remove a pause |
| `scripts/safe-write` | hashed, backed-up, logged writes |

## Quickstart

### 1. Install
```bash
# python3 (3.9+) and git
python3 --version && git --version
# ui-proof only (user-facing changes):
pip install playwright && python3 -m playwright install chromium
# one reviewer CLI for review-loop, from a different model family than your builder, e.g.:
#   grok CLI, claude CLI, or codex CLI, or any command that reads a prompt on stdin (cmd:)
```

### 2. Environment (minimal example)
```bash
export PATH="$PWD/scripts:$PATH"          # run from the template folder
export BOT_HOME="$HOME/bot-data"          # all logs live here
export SHIP_LANES="web,api"               # REQUIRED: your lane names
export AUDIT_MODE=shadow                  # shadow = report only, never pause
mkdir -p "$BOT_HOME/ship-gate" "$BOT_HOME/audit"
# optional: MODEL_LEDGER=$BOT_HOME/runs.jsonl  RESTRICTED_TERMS=secret-project  GATE_CLEAR_USER=auditor
```
Every path has a default under `$BOT_HOME`: `ship-log.jsonl`, `ship-gate/`, `audit/`, `review-loops/`, `ui-proof/`, `change-backups/`.

### 3. Wire ship-log into your lanes
Every ship records its proof first. `ship-log` exits non-zero (and the ship stops) when the lane is paused, the proof isn't from the head commit, a merge has no passing review loop, and so on.

Pre-push hook (`.git/hooks/pre-push`, made executable):
```bash
#!/usr/bin/env bash
set -e
HEAD=$(git rev-parse HEAD)
./scripts/verify.sh        # replace with YOUR verify command (tests/lint/build); must exit 0
ship-log --lane web --action push --ref "$HEAD" --agent "$USER" \
  --head-sha "$HEAD" --proof-commit "$HEAD" \
  --proof "verify.sh PASS on $HEAD; CI https://github.com/<owner>/<repo>/actions/runs/<id>"
```
Merge step in CI or your merge script (after the review loop passed on the head):
```bash
review-loop round --lane web --ref "$PR" --repo . --base main --brief brief.md \
  --builder-model "<builder-model>" --reviewer "claude:<reviewer-model>"   # up to 3 rounds
ship-log --lane web --action merge --ref "$PR" --head-sha "$HEAD" --proof-commit "$HEAD" \
  --proof "verify.sh PASS; CI https://github.com/<owner>/<repo>/actions/runs/<id>" && gh pr merge "$PR" --merge
```
Use `--dry-run` to run every check without writing anything.

### 4. First shadow audit and the canary
```bash
# a real (or test) ship row, run inside your repo (verify.sh = your verify command):
H=$(git rev-parse HEAD)
ship-log --lane web --action push --ref "$H" --head-sha "$H" --proof-commit "$H" \
  --proof "verify.sh PASS; CI https://ci.example/actions/runs/1"
# ship-log prints "wrote line N" on stderr; audit that line:
audit-row --line 1 --merged-sha "$H" --verify-cmd "./scripts/verify.sh" --repo .
#   -> {"verdict": ..., "ref": ".../audit/YYYY-MM-DD.jsonl#L1", ...}
# Items 11, 12 and 14 stay CANNOT-VERIFY until the bot reviews them in a fresh context (see skills/audit-a-ship),
# so a deterministic-only run never reports PASS on its own.

# seed a known-bad canary and confirm it FAILs:
seed-canary --lane web --kind sha-mismatch        # prints {"line": N, ...}
audit-row --line <N from the seed-canary output>   # must print "verdict": "FAIL" with "canary": true
```
A canary that isn't FAIL means the auditor is broken. Seed one every week.

### 5. Pauses and clearing (live mode only)
With `AUDIT_MODE=live`, an overall FAIL writes `<gate>/<lane>.paused` and `ship-log` exits 5 for that lane. After the fix:
```bash
gate-clear web --agent auditor --verdict-file "$BOT_HOME/audit/<date>.jsonl#L<fail>" --reaudit "$BOT_HOME/audit/<date>.jsonl#L<pass>"
```
The re-audit row must be JSON with `"verdict": "PASS"` exactly, for the same lane. A repeat failure needs `--approved-by <owner> --quote "<exact words>" --quote-ref <ref>`.

### Go-live criteria (from profile.md)
Start in SHADOW: report only to `<owner>` and `<coordinator>`, and place no holds until the owner says go live. Go live only after about **2 weeks of shadow**, a **100% canary catch rate**, and the **owner agreeing with the spot-check sample**. After go-live, a FAIL pauses that lane's auto-ship until it is fixed and re-audited.

## Security notes
- **Real enforcement is file permissions.** `gate-clear --agent auditor` and `GATE_CLEAR_USER` are speed bumps. Anyone who can write the gate directory can delete a `.paused` file. Make `$BOT_HOME/ship-gate` owned by the auditor's OS user with mode 755 (lanes can read it, only the auditor can write), and run lanes as a different user.
- **`cmd:<shell>` reviewer specs are code.** They run through `bash -c`. Set them yourself in config, and never build them from PR text, issue bodies, chat messages or any other untrusted input.
- The scripts never send, push or merge on their own. Your hooks and CI do that.

## License
MIT, see `LICENSE`.
