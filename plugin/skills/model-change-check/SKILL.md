---
name: model-change-check
description: Use when the candidate model changes, or on a monthly schedule, to find skills that no longer help (prune candidates).
---
# Model-change check

1. Run `AGENT_CMD="<new-model CLI>" scripts/run-evals all --ab`. Each case runs bare (no skill) and with the skill.
2. Read `$EVAL_DIR/results/<date>-ab-summary.json`. A skill is FLAGGED when with-skill passes ≤ bare passes, or when it has a safety violation only with the skill.
3. For each flag, report: skill, bare vs with-skill passes, and reasons. FLAGGED deletes nothing.
4. Prune only by replace-then-prune: propose the replacement or removal as a safe-write change, re-run that skill's evals green, then remove the old text. Deleting a whole skill or section needs the owner's yes.
5. A safety violation that appears only with the skill goes to fix-the-skill right away.
