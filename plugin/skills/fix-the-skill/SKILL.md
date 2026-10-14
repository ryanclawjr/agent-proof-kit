---
name: fix-the-skill
description: >-
  Makes the smallest safe edit to a skill after a repeated mistake or a missing,
  wrong, or misleading skill step. Use when the same correction has happened
  twice in a workflow a skill covers, or a skill step caused the problem. Prefer
  this over a memory note.
---
# Fix the skill

The lesson from a repeated mistake belongs in the skill that should have prevented it. A memory note helps one assistant; a fixed skill helps every assistant that runs it.

## When it applies
- The same mistake or correction has happened twice in work a skill covers, or
- The user corrects a step and says it should always be done that way, or
- The same multi-step chore keeps coming back.
One-off slips, taste calls and facts about a person go to memory, not a skill.

## Steps
1. Name the incident: what went wrong, when, and which skill step allowed it. With no real incident, stop. Don't edit on a hunch.
2. Find the skill that should have caught it. Only user-created skills can be edited. If a managed or plugin skill is the gap, add the step to the user skill that calls it, or report it.
3. Read the whole skill, then make the smallest edit that would have prevented the incident: one step, one check or one corrected line.
4. Keep it generic: no bot, repo or channel names and no private details.
5. Never loosen safety. Approval gates, stop-before-send, pay, push, deploy, merge and delete rules, scope limits and data isolation stay as strict or get stricter.
6. Never delete a skill or a whole section without the owner's yes.
7. Save through `scripts/safe-write` (the eval hook runs must-refuse cases and rolls back on regression), then write a dated log note: the skill, the change and the incident.
8. Prove it: add the incident as a `past-failure` case in `$EVAL_DIR/<skill>.eval.json` (create the set if it's missing: at least 3 normal and 2 must-refuse cases), run `scripts/run-evals <skill>`, and cite the result file. If any must-refuse case FAILs, revert and tell the owner.
9. Tell the user in one or two sentences in your next report.

## Repeated chores
If agents keep doing a multi-step chore by hand, prefer a small owned CLI plus a skill step that calls it over more prose. Keep the CLI generic, and the deny rules still apply.

## Code repos
For a repeated correction inside a code repo, the fix is a check in the repo (a test, lint or CI rule), not a skill edit.

## Don't
- Don't fix a skill after a single occurrence unless asked.
- Don't create a new skill when an existing one covers the work.
- Don't rewrite style or structure while you're in there.
