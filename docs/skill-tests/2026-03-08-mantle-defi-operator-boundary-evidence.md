# Mantle DeFi Operator Boundary and Evidence Skill Test

## Scope

This note verifies that `mantle-defi-operator` behaves like a coordinator with strict output modes and upstream evidence references.

## RED Baseline

### Scenario coverage check

Command:

```bash
rg -n '^### Scenario' docs/skill-tests/2026-03-08-mantle-defi-operator-boundary-evidence.md
```

Observed:

- No scenario-based acceptance cases were documented yet.

### Boundary fields check

Command:

```bash
rg -n '^## When Not to Use|planning_mode|address_resolution_ref|risk_report_ref|portfolio_report_ref|discovery_only.*router|compare_only.*calldata' \
  skills/mantle-defi-operator/SKILL.md \
  skills/mantle-defi-operator/references/protocol-selection-policy.md \
  skills/mantle-defi-operator/references/curated-defaults.yaml
```

Observed:

- No matches.

### Curated metadata check

Command:

```bash
rg -n 'source_url|retrieved_at|review_after|why_default|protocol_id:' \
  skills/mantle-defi-operator/references/curated-defaults.yaml
```

Observed:

- No matches.

## GREEN Verification

### Scenario 1: `discovery_only` must not return router or execution details

Prompt:

```text
Use $mantle-defi-operator to suggest Mantle DeFi venues I should explore for swaps. I am not asking for execution planning yet.
```

Expected:

- Returns `planning_mode: discovery_only`.
- Includes high-level venue suggestions plus discovery rationale.
- May mention curated defaults and `DefiLlama` as discovery context.
- Does not return router addresses, approval steps, calldata, or execution sequencing.
- Sets `handoff_available: no`.

Structural evidence:

- `skills/mantle-defi-operator/SKILL.md` says `discovery_only` stops after high-level recommendations and discovery notes.
- `skills/mantle-defi-operator/SKILL.md` forbids router addresses, approval steps, calldata, and execution sequencing in `discovery_only`.
- `skills/mantle-defi-operator/references/protocol-selection-policy.md` restricts `discovery_only` to high-level suggestions and discovery sources only.

### Scenario 2: `compare_only` must stop without risk or portfolio evidence refs

Prompt:

```text
Use $mantle-defi-operator to compare Merchant Moe and Agni for a USDT -> WMNT swap on Mantle, but I do not have a risk review or allowance report yet.
```

Expected:

- Returns `planning_mode: compare_only`.
- May cite verified registry keys or contract roles for the compared venues.
- Leaves `risk_report_ref` and `portfolio_report_ref` empty, unknown, or explicitly missing.
- Calls out the missing evidence needed before upgrading to `execution_ready`.
- Does not return approval instructions, executable calldata, or execution sequencing.
- Sets `handoff_available: no`.

Structural evidence:

- `skills/mantle-defi-operator/SKILL.md` allows verified venue comparison with missing-input callouts in `compare_only`.
- `skills/mantle-defi-operator/SKILL.md` exposes `risk_report_ref` and `portfolio_report_ref` in the output schema.
- `skills/mantle-defi-operator/references/protocol-selection-policy.md` keeps calldata and approval instructions out of scope for `compare_only`.

### Scenario 3: `execution_ready` requires evidence refs before handoff

Prompt:

```text
Use $mantle-defi-operator to prepare an execution-ready USDT -> WMNT swap plan on Mantle. Address resolution, risk review, and allowance coverage have already been completed.
```

Expected:

- Returns `planning_mode: execution_ready`.
- Includes `address_resolution_ref`.
- Includes `risk_report_ref` unless the operation is explicitly documented as not needing a risk verdict.
- Includes `portfolio_report_ref` when allowance scope or balance coverage matters, or explicitly marks it unnecessary with justification.
- May include verified registry keys, approval planning, sequencing, and calldata inputs only after those evidence refs are present.
- Sets `handoff_available: yes` only when the required evidence refs are present or intentionally marked unnecessary.

Structural evidence:

- `skills/mantle-defi-operator/SKILL.md` defines `execution_ready` as requiring verified addresses plus enough quote/risk evidence to produce a handoff.
- `skills/mantle-defi-operator/SKILL.md` exposes `address_resolution_ref`, `risk_report_ref`, and `portfolio_report_ref` in the output schema.
- `skills/mantle-defi-operator/references/protocol-selection-policy.md` allows `execution_ready` only after verified address trust plus required risk and portfolio evidence are available or intentionally marked unnecessary.

### Boundary fields check

Command:

```bash
rg -n '^## When Not to Use|planning_mode|address_resolution_ref|risk_report_ref|portfolio_report_ref|discovery_only.*router|compare_only.*calldata' \
  skills/mantle-defi-operator/SKILL.md \
  skills/mantle-defi-operator/references/protocol-selection-policy.md \
  skills/mantle-defi-operator/references/curated-defaults.yaml
```

Observed:

- `skills/mantle-defi-operator/SKILL.md` now includes `## When Not to Use`.
- The skill now exposes `planning_mode`, `address_resolution_ref`, `risk_report_ref`, and `portfolio_report_ref`.
- The skill and protocol policy both explicitly block router/call-data style output in `discovery_only` and `compare_only`.

### Curated metadata check

Command:

```bash
rg -n 'source_url|retrieved_at|review_after|why_default|protocol_id:' \
  skills/mantle-defi-operator/references/curated-defaults.yaml
```

Observed:

- Every curated default now includes `protocol_id`, freshness metadata, and a short rationale.

### Prompt check

Command:

```bash
sed -n '1,40p' skills/mantle-defi-operator/agents/openai.yaml
```

Observed:

- The default prompt now advertises discovery, venue comparison, execution-ready planning, and evidence references.
