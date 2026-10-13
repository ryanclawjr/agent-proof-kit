#!/usr/bin/env bash
set -u; export GATE_DIR=${GATE_DIR:-$(mktemp -d)}; rm -rf "$GATE_DIR"; mkdir -p "$GATE_DIR"; B=bin/gate-clear
echo "audit row: FAIL" > "$GATE_DIR/audit.txt"; echo "reaudit: PASS" > "$GATE_DIR/reaudit.txt"
$B pause web --by auditor --reason "audit.txt row 1 FAIL"
$B status web; echo "ship step sees exit $? (nonzero = blocked)"
$B clear web --by builder --verdict-file "$GATE_DIR/audit.txt" --reaudit "$GATE_DIR/reaudit.txt"; echo "builder clear exit $?"
$B clear web --by auditor --verdict-file "$GATE_DIR/audit.txt" --reaudit "$GATE_DIR/reaudit.txt"; echo "auditor clear exit $?"
$B pause web --by auditor --reason "second failure"
$B clear web --by auditor --verdict-file "$GATE_DIR/audit.txt" --reaudit "$GATE_DIR/reaudit.txt"; echo "repeat w/o human exit $?"
GATE_APPROVERS=owner $B clear web --by auditor --verdict-file "$GATE_DIR/audit.txt" --reaudit "$GATE_DIR/reaudit.txt" --approved-by owner --quote "ok to reopen web after the fix" --quote-ref "chat msg 123"; echo "repeat with human exit $?"
$B check >/dev/null; echo "gate check exit $?"
