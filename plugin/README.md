# Agent Proof Kit (plugin)

Make your agents prove it. Gates, tests and a review loop that answer "how do you know your agents follow the rules?" with evidence instead of summaries.

## Install
Install from the marketplace, or copy this folder to `~/.cursor/plugins/local/agent-proof-kit/`.
Needs Python 3 and git. Optional: `gh` (merge checks in `ship-log`), `gitleaks` (`secret-scan`).

Try it offline (mock agent and mock judge, no API keys):
```bash
scripts/run-evals evals/examples        # RESULT: PASS, planted bad answers caught 2/2
scripts/judge-check evals/examples      # exit 0; JUDGE_CMD="scripts/mock-judge --lazy" -> exit 3

# Required before any ship-log call: SHIP_LANES names the lanes (repo/deploy streams) the ship gate
# accepts and the auditor checks; ship-log exits 1 if unset. Use a comma list for several, e.g. web,api.
export SHIP_LANES=web
export BOT_HOME=/tmp/apk-demo   # where ship-log writes its logs
H=0123456789abcdef0123456789abcdef01234567
scripts/ship-log --lane web --action push --ref $H --head-sha $H --proof-commit $H --proof "verify PASS" --dry-run   # exit 0, prints the row
scripts/ship-log --lane web --action merge --ref 12 --head-sha $H --proof-commit $H --proof "verify PASS" --dry-run  # exit 9: no review-loop verdict
```
Scripts call each other from `scripts/`; you don't need them on PATH (optional: `export PATH="$PWD/scripts:$PATH"`).

## Components
| Kind | Name | What it does |
|---|---|---|
| Skill | `audit-a-ship` | Audit one shipped change against its gate, evidence only; pause the lane on FAIL |
| Skill | `review-loop` | Fresh-context, different-model-family review before merge, max 3 rounds |
| Skill | `write-evals` | Write a JSON eval set: normal, must-refuse, past-failure, planted bad answers |
| Skill | `fix-the-skill` | Turn an incident into a skill fix plus a permanent past-failure case |
| Skill | `model-change-check` | Re-test each skill bare vs. with-skill after a model change (`--ab`) |
| Command | `/ship-check` | Dry-run the ship gate and list every refusal reason |
| Command | `/run-evals` | Judge check, then eval run, then a summary |
| Scripts | `scripts/` | `ship-log`, `review-loop`, `gate-clear`, `ui-proof`, `audit-row`, `safe-write`, `run-evals`, `judge-check`, `mock-agent`, `mock-judge`, `secret-scan`, `tool-tiers-gen` |
| Templates | `templates/` | `skill.eval.json`, `role_profile.yaml`, `tool-tiers.json`, `proof-matrix.md` |

## Eval format
One JSON file per skill, `<skill>.eval.json` (see `evals/example.eval.json` = `templates/skill.eval.json`):
`skill`, `skill_path` (absolute, or relative to the eval file), `version`, `owner`, and `cases[]` with
`id`, `type` (`normal` | `must-refuse` | `past-failure`), `prompt`, `expect`, `must_not[]`, optional
`must_not_regex[]`, `source`, and `planted_bad_answers[]` (`{id, why_bad, answer}`) that the judge must FAIL.

`run-evals <skill|all|dir|file>`: exit 0 pass, 1 a normal case missed, 2 nothing to run, 3 safety (must-not violated, case errored, or judge missed a planted answer). `--only-type TYPE`, `--out DIR`, `--jobs N`, `--ab`.

## Environment variables
| Variable | Used by | Default | Meaning |
|---|---|---|---|
| `AGENT_CMD` | run-evals | `scripts/mock-agent` | Candidate agent: any command reading the prompt on stdin, answer on stdout |
| `JUDGE_CMD` | run-evals, judge-check | `scripts/mock-judge` | Judge: must print `{"verdict":"PASS\|FAIL","violated_must_not":[],"reason":""}`; use a different model family than the agent |
| `HOUSE_RULES` | run-evals | built-in approval rule | Rules prepended to every candidate prompt |
| `BOT_HOME` | all gate scripts | `~/bot-data` | Root for logs, ledgers, gate files and evals |
| `EVAL_DIR` | run-evals, safe-write | `$BOT_HOME/evals`, else `./evals` | Eval sets; results go to `$EVAL_DIR/results/` |
| `SKILL_ROOTS` | safe-write | — | Colon-separated skill folders whose edits trigger the eval hook |
| `RUN_EVALS_BIN` | safe-write | `run-evals` on PATH | Path to `scripts/run-evals` |
| `SAFE_WRITE_ROOT` | safe-write, ship-log, gate-clear | under `$BOT_HOME` | Backups and the hashed write log |
| `SAFE_WRITE_EVAL_TIMEOUT` | safe-write | `900` | Seconds for the eval hook |
| `SHIP_LANES` | ship-log, gate-clear, audit-row | — (required) | Comma-separated lane names, e.g. `web,api` |
| `SHIP_GATE` / `SHIP_LOG` | ship-log, gate-clear, audit-row | under `$BOT_HOME` | Pause-file folder and the ship log |
| `MODEL_LEDGER` | ship-log | unset (check off) | If set, a ship needs a ledger entry for its lane |
| `GATE_CLEAR_USER` | gate-clear | — | Who is clearing; only the auditor may clear a pause |
| `AUDIT_LOG_DIR` / `AUDIT_MODE` | audit-row, audit-a-ship | under `$BOT_HOME` / `shadow` | Audit log folder; `shadow` reports only, `live` pauses lanes |
| `REVIEW_LOOP_ROOT` / `REVIEW_LOOP_BIN` / `REVIEW_LOOP_AGENT` | review-loop, ship-log, audit-row | under `$BOT_HOME` | Review loop records, binary and agent name |
| `GROK_BIN`, `COMMENT_CHECK_BIN`, `HYGIENE_BLOCKING_FROM`, `RESTRICTED_TERMS` | review-loop | — | Reviewer CLI, optional comment checker, hygiene threshold, terms the reviewer must never echo |
| `UI_PROOF_ROOT` / `UI_PROOF_BIN` / `UI_PROOF_AGENT` / `BASE_URL` | ui-proof, ship-log | under `$BOT_HOME` | UI proof records for user-facing ships |
| `PROOF_DIR` | secret-scan | `./proof` | Report folder (created if missing) |
| `GITLEAKS` / `SECRET_SCAN_CONFIG` | secret-scan | `gitleaks` / `config/secret-scan.toml` | Scanner binary and config |

## Safety
Nothing here sends, pushes, merges or deploys on its own. The gates refuse and log; a named human approves every irreversible act.

Full docs: https://github.com/ryanclawjr/agent-proof-kit · License: MIT
