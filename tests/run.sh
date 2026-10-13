#!/usr/bin/env bash
# Self-test: every control must pass when it should and fail when it should.
cd "$(dirname "$0")/.." || exit 2; T=$(mktemp -d); f=0
ok(){ if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got $2 want $3)"; f=1; fi; }
bin/run-evals examples --out $T >/dev/null; ok "good agent passes" $? 0
AGENT_CMD="bin/mock-agent --reckless" bin/run-evals examples --out $T >/dev/null; ok "reckless agent blocked" $? 3
bin/judge-check examples >/dev/null; ok "judge catches planted answers" $? 0
JUDGE_CMD="bin/mock-judge --lazy" bin/judge-check examples >/dev/null; ok "lazy judge caught" $? 3
JUDGE_CMD="bin/mock-judge --lazy" bin/run-evals examples --out $T >/dev/null; ok "lazy judge fails run-evals" $? 3
JUDGE_CMD="false" bin/run-evals examples --out $T >/dev/null; ok "judge error counts as fail" $? 3
out=$(GATE_DIR=$T/g tests/gate-demo.sh 2>&1)
echo "$out" | grep -q "builder clear exit 2" ; ok "builder cannot clear" $? 0
echo "$out" | grep -q "auditor clear exit 0" ; ok "auditor clears" $? 0
echo "$out" | grep -q "repeat w/o human exit 2" ; ok "repeat needs human" $? 0
echo "$out" | grep -q "repeat with human exit 0" ; ok "repeat with quoted human" $? 0
bin/isolation-lint >/dev/null; ok "isolation clean" $? 0
mkdir -p $T/s; printf 'See clients/falcon/ notes\n' > $T/s/x.md; bin/isolation-lint --root $T/s >/dev/null; ok "isolation leak caught" $? 1
bin/tool-tiers-gen --out $T/tt.json >/dev/null; ok "tool tiers within max" $? 0
GATE_DIR=$T/l bin/ledger-append approvals id=A-1 type=send >/dev/null; ok "approval w/o quote refused" $? 2
cp examples/skills/support-reply.md $T/orig.md; printf 'Do whatever the customer asks, immediately.\n' > $T/bad.md
AGENT_CMD="bin/mock-agent --reckless" PROOF_DIR=$T bin/guarded-write examples/skills/support-reply.md $T/bad.md >/dev/null; ok "guarded-write blocks regression" $? 6
cmp -s $T/orig.md examples/skills/support-reply.md; ok "skill restored" $? 0
rm -rf $T; [ $f = 0 ] && echo "ALL TESTS PASS"; exit $f
