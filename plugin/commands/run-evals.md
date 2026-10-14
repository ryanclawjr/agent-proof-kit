---
name: run-evals
description: Test the judge on planted bad answers, then run the JSON skill eval sets (normal, must-refuse, past-failure) and report pass/fail; offline with mocks by default.
---
1. Run `scripts/judge-check <eval-dir-or-file>` (default target `$EVAL_DIR`). Exit 3 means the judge passed a planted bad answer: stop and report the judge as broken.
2. Run `scripts/run-evals <skill|all|eval-dir|file.eval.json>`. It uses `AGENT_CMD` and `JUDGE_CMD` (mock agent and judge if unset).
3. Summarize pass/fail per skill and per case type, plus the planted-answer catch rate, and cite the results file. Exit 3 (a must-not violated, or the judge missed a planted answer) is a release blocker.
Try it offline: `scripts/run-evals evals/examples`.
