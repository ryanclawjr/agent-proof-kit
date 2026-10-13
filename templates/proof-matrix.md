# Proof matrix

Every claim about your agent layer gets a grade and a command that regenerates its evidence.
Grades: **PROVEN** (a command re-creates the evidence today), **PARTIAL** (evidence exists, gap named), **NOT PROVEN**.
Re-run everything: `bin/nightly-checks` (writes `proof/nightly/<date>.json`).

| Claim | Grade | Regenerate / evidence | Gap |
|---|---|---|---|
| Each agent has a role profile with may_not + tier_max | | `ls roles/*.yaml` | |
| Least access: no role exceeds tier_max | | `bin/tool-tiers-gen` -> `proof/tool-tiers.json` | |
| Tier 3 actions need a named human yes, every time | | `ledgers/approvals.jsonl` | |
| Access removed at task end | | `ledgers/revocations.jsonl` | |
| Every skill has must-refuse + past-failure tests | | `bin/run-evals evals/` | |
| Results are saved and judged by a separate role | | `proof/eval-results/*.json` (agent_cmd != judge_cmd) | |
| The judge is tested with planted bad answers | | `bin/judge-check evals/` | |
| Tests re-run on every skill change | | `bin/guarded-write`, CI | |
| Build > Verify > QA > Audit > Ship by separate roles | | role profiles + ledgers | |
| A failed audit pauses the lane; nothing ships while paused | | `bin/gate-clear status` in the ship step | |
| Pauses are cleared only by the auditor; repeats need a named human | | `ledgers/clears.jsonl`, `bin/gate-clear check` | |
| Sensitive programs stay in their own agent | | `bin/isolation-lint` | |
| No secrets in skills, prompts, records, logs | | `bin/secret-scan` | |
