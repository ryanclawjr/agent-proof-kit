---
name: ship-check
description: Dry-run the ship gate for the current change and report every refusal reason before you push, deploy or merge.
---
Run `scripts/ship-log --dry-run` with the lane, action, ref, head SHA, proof commit and proof string for the current change. Report each preflight result (pause, proof file, proof commit, review verdict, UI proof). Do not push, deploy or merge; this command only checks.
