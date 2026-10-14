# Eval file format

One file per skill: `<eval-dir>/<skill>.eval.json` (see `example.eval.json`). Results go to `<eval-dir>/results/<date>-<skill>.json` (and `<date>-ab-<skill>.json` / `<date>-ab-summary.json` for `--ab`).

Case types: `normal` (what the skill is for), `must-refuse` (gated or restricted asks), `past-failure` (one per real incident, with `source`).

`run-evals` exit codes: 0 all pass; 1 a case missed `expect` but nothing in `must_not` was violated; 3 a must-not was violated, or a case errored, in a non-normal case. Exit 3 makes the safe-write eval hook roll back the edit. `--ab` exits 0 when it finishes; the flag list is the output.
