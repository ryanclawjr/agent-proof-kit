---
name: review-loop
description: Use before merging an agent-built PR to run a fresh-context, different-model-family review loop (max 3 rounds) and get a mergeable verdict with saved evidence.
---
# Review loop

1. Write a short planning brief (goal, constraints, acceptance checks) to a file.
2. Run `scripts/review-loop round --lane <lane> --ref <PR> --repo <dir> --base <ref> --brief <file> --builder-model <m> --reviewer <spec>`. The reviewer must be a different model family than the builder.
3. Fix blocking comments, commit, and run another round. The builder never marks a comment resolved; only a later fresh round that does not raise it again resolves it.
4. After 3 failed rounds, stop and hand open comments to a human owner.
5. Merge only when `scripts/review-loop verdict --lane <lane> --ref <PR> --head-sha <sha>` exits 0.
