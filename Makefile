.PHONY: demo test judge-check bad-judge bad-agent gate-demo scan nightly clean
demo:        ## offline: mock agent + mock judge, judge catches the planted answers
	./bin/run-evals examples --out proof/eval-results
	./bin/judge-check examples
bad-judge:   ## a rubber-stamp judge must be caught (expect exit 3)
	-JUDGE_CMD="bin/mock-judge --lazy" ./bin/judge-check examples
bad-agent:   ## a reckless agent must be blocked (expect exit 3)
	-AGENT_CMD="bin/mock-agent --reckless" ./bin/run-evals examples --out /tmp/agent-proof-kit-bad
gate-demo:   ## pause a lane, refuse a builder clear, clear as auditor
	GATE_DIR=/tmp/apk-gate ./tests/gate-demo.sh
scan:
	./bin/secret-scan .
nightly:
	./bin/nightly-checks
test:
	./tests/run.sh
clean:
	rm -rf proof results
