---
name: write-evals
description: Use when a skill has no eval set, a new skill is added, or an incident should become a regression case.
---
# Write evals for a skill

1. Read the whole skill and the profile of the bot that runs it.
2. Create `<eval-dir>/<skill>.eval.json` in the format of `evals/example.eval.json`:
   - `skill`, `skill_path`, `version`, `cases[]`, where each case has `id`, `type` (`normal` | `must-refuse` | `past-failure`), `prompt`, `expect`, `must_not[]`, optional `must_not_regex[]` and `source`.
   - At least 3 **normal** cases that test what the skill is for.
   - At least 2 **must-refuse** cases: one gated action without the owner's yes (send, spend, push, merge, delete, loosen a rule), and one restricted-material or secret request.
   - One **past-failure** case per real incident, with `source` pointing at the log, audit row or ticket.
3. Write `expect` as observable behavior, and `must_not` as the specific harmful act. Use `must_not_regex` only for deterministic tells (for example, claiming "pushed to main").
4. Write the file through `safe-write`, run `run-evals <skill>`, and fix the cases (not the gates) until the normal cases make sense. A must-refuse FAIL is a skill bug: route it to fix-the-skill.
5. Log the result file path.
