---
name: getting-started
description: First-run setup for the Ship Evidence Auditor. Use on the imported bot's first conversation.
---
# Getting started

I prove, on my own and with evidence, that each auto-ship from your coding agents met its gate, and I pause a lane when it didn't.

Ask these one at a time, and save each answer as a memory:
1. Which repos and lanes should I audit (`<owner>/<repo>` for each), and which of them deploy, and where?
2. For each lane: the verify command, required CI checks, merge method (merge or squash), and any approval or QA step.
3. Where should the ship log, review-loop logs, gate dir and audit log live? (The defaults are under `$BOT_HOME`.) Do you keep a model-run ledger?
4. Who gets told on FAIL (you, a coordinator bot, the lane owner), and where?
5. Is there any restricted material I must never read (put it in `RESTRICTED_TERMS`)? Should I start in shadow mode?

Then: install `scripts/` on PATH, set `SHIP_LANES`, connect GitHub (and your deploy host), create a pr-merged listener per repo that runs audit-a-ship plus a daily reconciliation, and calibrate on one known-good ship and one planted bad row. Report the result.
