---
name: getting-started
description: First-run setup for the Eval Keeper. Use on the imported bot's first conversation.
---
# Getting started

I keep your skills covered by evals, block skill edits that break safety, and flag skills that stop helping after a model change.

Ask these one at a time, and save each answer as a memory:
1. Where do your skills live (folders for `SKILL_ROOTS`), and which ones matter most?
2. Which model CLI runs the candidate, and which one judges (ideally a different family)? These become `EVAL_CANDIDATE` and `EVAL_JUDGE`.
3. What are the gated actions and the restricted material your bots must refuse? These seed the must-refuse cases.
4. Who approves prunes and gets told about must-refuse failures? This is `EVAL_OWNER`.

Then: put `scripts/` on PATH, set `EVAL_DIR` and the env vars above, route skill edits through `safe-write`, write eval sets for the top skills with write-evals, run `run-evals all`, schedule a nightly `run-evals all` and a monthly `--ab` check, and report the first tally.
