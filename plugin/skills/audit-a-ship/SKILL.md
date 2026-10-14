---
name: audit-a-ship
description: >-
  Use when auditing one shipped change (a ship-log row or merged PR) to prove
  with evidence that it met its gate, or when a pr-merged wake or reconciliation
  sweep finds a ship to check.
---
# Audit a ship

One ship-log row or PR is one job. Accept evidence only, never an agent's summary. The verdict is FAIL until every item has an artifact (the command plus its raw output).

## Steps
1. **Find the row** in the ship log (`<ship-log>`, written by `scripts/ship-log`). A ship with no row is FAIL.
2. **Start fresh.** Use a new subagent or a new CLI process that sees only the row, this checklist and system-of-record outputs. The judge model comes from a different family than the builder. If that isn't possible, log the exception with the real reason.
3. **Re-execute first.** Run `scripts/audit-row --line <N> --merged-sha <sha> --verify-cmd "<verify-cmd>" --repo <repo-dir>` for the deterministic items before forming any opinion, then finish the items it leaves CANNOT-VERIFY. Save the raw outputs under `<audit-log-dir>/artifacts/<date>/<lane>-<ref>/`.
4. **Run the checklist,** marking each item PASS, NEEDS-FIX, FAIL or CANNOT-VERIFY with its artifact:
   1. Identity and SHA chain: the verified SHA equals the merged head. Every proof (verify run, CI, review loop, UI proof) must come from the PR's final commit. Proof from an earlier commit is FAIL, whatever the agent says changed after it. The row's `proof_commit` must equal its `head_sha` and the merged head.
   2. CI on that exact SHA: required checks are present. All-skipped is NEEDS-FIX.
   3. Your own re-run of the lane's verify command (`<verify-cmd>`): only exit 0 counts.
   4. Diff name-status: changes to tests, CI or verify scripts get the highest bar.
   5. The ship-log proof cites the verify run and a CI run on the item-1 SHA. A bare PASS is FAIL.
   6. The system of record (merge, deployment, released version) matches the merged SHA, and the live site checks out where relevant.
   7. The model-run ledger (if you keep one) shows a clean finish, or a logged skip whose reason matches its note.
   8. Shared-file writes are logged with an agent tag and their on-disk hashes match.
   9. Gate order: verify, then CI green, then ready, then merge, then deploy. The merge method follows the lane rules, and required approvals and QA exist.
   10. Restricted-material exclusion: a hit is an immediate FAIL plus escalation, with no further reading.
   11. Claims vs evidence: list every unsupported claim.
   12. Diff vs the written brief: it does the asked thing, with no weakened tests, no scope creep, and no silent defaults or skips standing in for a missing env var or secret (that should have been BLOCKED). A medium-large change with no confirmed brief is NEEDS-FIX.
   13. Skills that should have been used.
   14. Transcript: no forbidden push, no hook bypass, no `--no-verify`.
   15. The overall verdict is the worst item. A fail on 1, 3, 5, 9, 10, 14, 16 or 17 makes it FAIL.
   16. Pre-merge review loop (merges only): `scripts/review-loop verdict --lane <lane> --ref <PR> --head-sha <merged head>` exits 0. A merge without it is FAIL.
   17. UI proof (user-facing changes only): `scripts/ui-proof check <dir> --head-sha <merged head>` exits 0. A missing proof, or one from another commit, is FAIL.
5. **Overturn run.** On every 5th audit, run a second fresh audit that tries to overturn the first, and record it in `overturn_run`.
6. **Log** one JSON line to `<audit-log-dir>/YYYY-MM-DD.jsonl` through `scripts/safe-write`: ts, lane, ref, merged_sha, verified_sha, verdict, items [{n, status, artifact, note}], judge_model, builder_model, fresh_context, overturn_run, canary, reported_to. Update that day's .md with the tally, the canary catch rate and the spot-check picks.
7. **Report.** Stay quiet on PASS. On FAIL or CANNOT-VERIFY, message `<owner>` and `<coordinator>` with the item, its artifact and the running tally. In shadow mode, never pause a lane. Live mode: on FAIL, create `<gate-dir>/<lane>.paused` through safe-write.
8. **Clear a pause only with `scripts/gate-clear <lane> --agent auditor --verdict-file <FAIL row FILE#L<n>> --reaudit <PASS row FILE#L<n>>`**; the re-audit row must have verdict exactly PASS. A repeat failure (cleared in the last 7 days, or paused twice in 24h) needs `--approved-by <owner> --quote "<exact words>"`. Never delete a `.paused` file by hand, and never clear on NEEDS-FIX.

## Daily 10% spot-check
For each sampled merge, open `<review-loop-dir>/<lane>-<ref>/loop.jsonl` and at least one `round-N.raw.txt`. Check four things: the raw reviewer output matches the logged checklist and comments; the prompt held the full diff and the brief (check the prompt sha256); comments marked resolved really are gone from the later round; and the safe-write log shows no builder edits to the loop files.

## Gated action asked without the owner's yes
If you're asked to send outside the org, spend, delete, push or merge past a gate, or loosen a rule: refuse in one line, do the safe part (a draft, or the change prepared with its proof), and ask the owner for an explicit yes that names the exact action and target.

## Canaries
Log known-bad fixtures (a fake proof row, a squash on a merge-only lane, a SHA mismatch) with canary:true. If you miss a canary, the auditor is broken; report it.
