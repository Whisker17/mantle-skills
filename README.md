# Mantle Skills

This repository contains a curated set of Mantle-focused agent skills.

Each skill packages reusable instructions, safety rules, and supporting references for a recurring Mantle task. The repo is designed for agent runtimes that load filesystem-based skills from `SKILL.md` files and optional local resources.

## What This Repo Contains

- Mantle-specific operational skills for DeFi planning, risk checks, address safety, portfolio inspection, simulation handoff, and smart-contract workflows
- A Mantle onboarding/reference skill for clarifying network-specific concepts that are easy to misunderstand
- Local references and assets that keep responses reproducible, auditable, and less dependent on model memory

## Repository Layout

Each skill lives under `skills/<skill-name>/` and usually includes:

- `SKILL.md` — the main skill definition, trigger conditions, workflow, and guardrails
- `agents/openai.yaml` — runtime-facing metadata such as display name and default prompt
- `references/` — supporting playbooks, templates, or policy documents
- `assets/` — machine-readable local data when needed

Supporting docs for design notes, review notes, and skill tests live under `docs/`.
Eval definitions, runner implementation, and eval outputs live under `evals/`.

## Skill Categories

### 1. Onboarding and Reference

These skills explain Mantle-specific concepts and help prevent incorrect assumptions before execution work begins.

- `mantle-network-primer` — reference/onboarding skill for Mantle fundamentals, MNT gas, chain setup, inclusion, settlement, finality, and live-verify boundaries

### 2. Registry and Safety Gates

These skills establish trusted inputs and safety checks before any execution-ready plan is produced.

- `mantle-address-registry-navigator` — resolves verified contract and token addresses from trusted sources
- `mantle-risk-evaluator` — returns pre-execution `pass` / `warn` / `block` verdicts for state-changing intents
- `mantle-portfolio-analyst` — inspects balances, allowances, and approval exposure with read-only data

### 3. Analytics and Diagnostics

These skills answer historical questions, debug read-path problems, and prepare simulation evidence.

- `mantle-data-indexer` — queries indexers for historical wallet activity, time-windowed metrics, and protocol analytics
- `mantle-readonly-debugger` — triages RPC failures, quote reverts, and inconsistent read-path behavior
- `mantle-tx-simulator` — prepares external simulation handoffs and translates results into WYSIWYS summaries

### 4. DeFi Planning

These skills coordinate venue selection and pre-execution planning for Mantle DeFi actions.

- `mantle-defi-operator` — orchestrates discovery, venue comparison, and execution-ready DeFi planning with verified contracts and supporting evidence

### 5. Smart Contract Lifecycle

These skills cover contract planning and deployment handoff across the Mantle contract lifecycle.

- `mantle-smart-contract-developer` — handles Mantle-specific contract requirements, architecture, dependencies, access control, and deployment-readiness decisions
- `mantle-smart-contract-deployer` — handles deployment-readiness checks, external signer handoff, receipt capture, and explorer verification

## Skill Index

| Skill | Category | Purpose |
| --- | --- | --- |
| `mantle-network-primer` | Onboarding and Reference | Clarify Mantle-specific concepts and developer onboarding assumptions |
| `mantle-address-registry-navigator` | Registry and Safety Gates | Resolve verified addresses and prevent unsafe address guesses |
| `mantle-risk-evaluator` | Registry and Safety Gates | Apply pre-execution risk thresholds and verdicts |
| `mantle-portfolio-analyst` | Registry and Safety Gates | Inspect balances, allowances, and approval risk |
| `mantle-data-indexer` | Analytics and Diagnostics | Retrieve historical and aggregated Mantle activity from indexers |
| `mantle-readonly-debugger` | Analytics and Diagnostics | Diagnose read-only failures and ambiguous RPC behavior |
| `mantle-tx-simulator` | Analytics and Diagnostics | Prepare simulation handoffs and explain expected outcomes |
| `mantle-defi-operator` | DeFi Planning | Coordinate discovery, comparison, and execution-ready DeFi plans |
| `mantle-smart-contract-developer` | Smart Contract Lifecycle | Frame Mantle-specific contract design and readiness decisions |
| `mantle-smart-contract-deployer` | Smart Contract Lifecycle | Prepare deployment and verification handoffs |

## How to Use the Skills

- Choose the skill whose trigger conditions best match the task
- Read `SKILL.md` first; it defines when the skill applies, what workflow to follow, and which guardrails to enforce
- Load only the specific `references/` or `assets/` files needed for the current task
- Prefer specialized skills over broad ones when the task is narrow
- Use orchestrator skills, such as `mantle-defi-operator`, only when the task genuinely spans multiple sub-problems

## Design Principles

- Trigger-first descriptions so runtimes can retrieve the right skill
- Fail-closed safety for addresses, execution claims, and stale data
- File-backed references for reproducibility and lower hallucination risk
- Clear separation between reference/onboarding skills and execution-oriented skills
- Small, composable skill boundaries where possible

## Notable Positioning

- `mantle-network-primer` is intentionally a reference/onboarding skill rather than a pure execution operator
- `mantle-defi-operator` is intentionally an orchestrator and should rely on supporting evidence from specialized skills instead of re-deriving everything itself

## Evals

This repo includes an in-repo eval suite under `evals/` for measuring whether loading a Mantle skill improves answer quality relative to the bare model.

### Requirements

- `bash`, `curl`, `jq`, and either `yq` or `python3` with PyYAML available
- one of:
  - `OPENAI_API_KEY` for `openai/*`
  - `OPENROUTER_API_KEY` for `openrouter/*`
- A model string in `provider/model` format such as `openai/gpt-5.2` or `openrouter/openai/gpt-5.2`

### Run an Eval

```bash
./evals/runner/run.sh --skill network-primer --model openai/gpt-5.2
```

```bash
./evals/runner/run.sh --skill network-primer --model openrouter/openai/gpt-5.2
```

For OpenRouter, the runner also supports:

- `OPENROUTER_BASE_URL` — override the default `https://openrouter.ai/api/v1`
- `OPENROUTER_HTTP_REFERER` — optional attribution header
- `OPENROUTER_TITLE` — optional application title header

The runner writes a timestamped JSON report to `evals/results/`. Each report includes:

- bare-model answers and judged verdicts
- skill-loaded answers and judged verdicts
- per-eval comparison (`skill_better`, `same`, `bare_better`)
- summary pass/fail counts for both variants

### Files

- `evals/*.yaml` — per-skill eval definitions
- `evals/runner/load-skill.sh` — bundles `SKILL.md` plus local references/assets into one prompt context
- `evals/runner/judge.md` — judge prompt used to grade answers against `expected_facts` and `fail_if`
- `evals/results/.gitkeep` — keeps the output directory in git while ignoring generated JSON reports

## Related Docs

- `docs/skills-review-2026-03-08.md` — current review notes, including `mantle-network-primer` positioning
- `docs/skill-tests/` — retrieval and boundary checks for selected skills
- `docs/plans/` — design and implementation notes for larger skill changes
