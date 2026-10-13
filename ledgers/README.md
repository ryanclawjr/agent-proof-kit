# Ledgers (append-only JSONL)

Never edit or delete a row. To correct one, append a new row with `"supersedes": "<id>"`.

## approvals.jsonl — a named human said yes to a tier-3 action
```json
{"id":"A-001","ts":"2026-01-05T09:30:00-05:00","type":"send|spend|delete|loosen|push","scope":"what exactly was approved","approved_by":"<name>","quote":"their exact words","ref":"where they said it (message link/id)","expires":"optional: once | ISO date"}
```
Write with `bin/ledger-append approvals id=A-001 type=send scope=... approved_by=... quote=... ref=...`.

## revocations.jsonl — access removed when a task ended
```json
{"ts":"...","agent":"<role or agent>","revoked":"what access","mechanism":"how it was removed","evidence":"file/command that proves it"}
```

## pauses.jsonl / clears.jsonl — the ship gate (written only by `bin/gate-clear`)
```json
{"lane":"web","paused_at":"...","paused_by":"auditor","reason":"audit row ref"}
{"lane":"web","paused_at":"...","pause_sha256":"...","cleared_at":"...","cleared_by":"auditor","verdict_file":"...","reaudit_pass":"...","repeat_failure":false,"approved_by":null,"quote":null,"quote_ref":null}
```
