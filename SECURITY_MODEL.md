# Security model

Threat model for agent-proof-kit. This repository is part of the owner's **research-pipelines** component: operator-run tooling, not an internet-facing service. Answers from the owner are marked **(owner)**. Devin security scans rank their findings against this model, so edit it when the tools or their priorities change.

## System overview and trust boundaries

agent-proof-kit is a Cursor plugin (`.cursor-plugin/marketplace.json`, `plugin/`) of local command-line scripts (`plugin/scripts/`) that gate what autonomous coding agents may ship: gates and `gate-clear`, the cross-model review loop, eval sets with must-refuse cases, safe-write, UI proof bundles recorded with Playwright, the ship log and its audit rows, and the model ledger. There is no server, ingress or deploy config. Trust boundaries:

1. **Agent -> gate scripts**: an agent working in the operator's lane runs the scripts that are meant to hold it back. The scripts' verdicts and proof files are the control.
2. **Steps files and repository content -> Playwright UI proof**: page content and steps files drive a browser.
3. **Marketplace -> users' machines**: the plugin's scripts and skills run on whoever installs it (supply-chain surface).

## Assets

- Integrity of gate verdicts, review verdicts, eval results, UI proofs and ship-log audit rows (a forged PASS lets an agent ship unchecked work).
- Files on the operator's machine that safe-write and the proof tools can reach.
- The plugin as distributed to other users.

## Attacker profiles

**(owner)** All of these matter.

1. A misbehaving or compromised agent in the operator's lane trying to clear its own gate, forge a review or proof, or keep a change that fails its evals.
2. Malicious content (a page under test, a steps file, a repository) steering the proof tools.
3. Supply chain: a tampered plugin release or dependency.

## Existing controls

Hash-checked atomic writes with rollback in safe-write, cross-family review requirement, must-refuse eval cases, deterministic audit rows, proof bundles tied to the ship log.

## Out of scope / accepted risk

**(owner)** Nothing is out of scope or accepted risk; every finding matters, including local-only tooling.
