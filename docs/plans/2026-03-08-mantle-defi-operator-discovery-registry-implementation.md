# Mantle DeFi Operator Discovery Registry Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add curated Mantle DeFi protocol discovery to `mantle-defi-operator` while keeping all verified contract addresses in the shared `mantle-address-registry-navigator` registry.

**Architecture:** Reuse `mantle-address-registry-navigator/assets/registry.json` as the single source of truth for contract addresses. Store curated protocol preferences and recommendation rules in `mantle-defi-operator/references/`, then update both skills so the operator recommends curated defaults first, ranks eligible protocols with live metrics, and clearly separates verified execution targets from discovery-only mentions.

**Tech Stack:** Markdown skill docs, JSON registry data, YAML reference files, `rg`, `jq`, `python3`

---

## Pre-Flight

This plan assumes execution happens inside a real git worktree for this repo.

Run: `git rev-parse --show-toplevel`
Expected: prints the repo root path

If the command fails, stop and reopen the task in the intended worktree before making changes. All commit steps below assume git is available.

### Task 1: Capture RED Baseline for the Skill Change

**Files:**
- Create: `docs/skill-tests/2026-03-08-mantle-defi-operator-discovery.md`
- Test: `mantle-defi-operator/SKILL.md`
- Test: `mantle-address-registry-navigator/assets/registry.json`

**Step 1: Write the failing pressure scenarios**

Create `docs/skill-tests/2026-03-08-mantle-defi-operator-discovery.md` with these baseline scenarios:

```markdown
# Mantle DeFi Operator Discovery Skill Test

## Scenario 1: Swap recommendation
Prompt:
"Use $mantle-defi-operator to plan a USDT -> WMNT swap on Mantle. Recommend the best protocol and provide the router address."

Expected after implementation:
- Mentions curated defaults first (`Merchant Moe`, `Agni`)
- Uses verified registry-backed address names
- Explains recommendation with liquidity / volume language

## Scenario 2: Lending recommendation
Prompt:
"Use $mantle-defi-operator to plan a WMNT supply flow on Mantle and suggest a lending venue."

Expected after implementation:
- Suggests `Aave v3` first
- States whether live metrics were available
- Separates recommendation from execution

## Scenario 3: Discovery-only alternative
Prompt:
"What other Mantle DeFi protocols should I look at besides your defaults?"

Expected after implementation:
- Returns curated defaults first
- Mentions external discovery via `DefiLlama`
- Does not invent unverified addresses
```

**Step 2: Run baseline checks to prove the feature is missing**

Run: `rg -n "Merchant Moe|Agni|Aave v3|DefiLlama|curated defaults|also_viable|not_recommended" mantle-defi-operator/SKILL.md`
Expected: no matches

Run: `jq -e '.contracts[] | select(.key=="MERCHANT_MOE_ROUTER")' mantle-address-registry-navigator/assets/registry.json`
Expected: non-zero exit because the entry does not exist yet

**Step 3: Record the RED results**

Append the actual baseline outputs to `docs/skill-tests/2026-03-08-mantle-defi-operator-discovery.md` under a `## RED Baseline` section.

**Step 4: Commit the baseline**

```bash
git add docs/skill-tests/2026-03-08-mantle-defi-operator-discovery.md
git commit -m "test: capture discovery baseline for mantle defi operator"
```

### Task 2: Extend the Shared Address Registry for Curated Protocols

**Files:**
- Modify: `mantle-address-registry-navigator/assets/registry.json`
- Modify: `mantle-address-registry-navigator/references/address-registry-playbook.md`
- Modify: `mantle-address-registry-navigator/SKILL.md`
- Test: `mantle-address-registry-navigator/assets/registry.json`

**Step 1: Write the failing registry expectations**

Add a new section to `docs/skill-tests/2026-03-08-mantle-defi-operator-discovery.md` listing the exact registry keys that must exist after this task:

```markdown
## Required registry keys
- MERCHANT_MOE_ROUTER
- MERCHANT_MOE_LB_ROUTER
- MERCHANT_MOE_LB_QUOTER
- AGNI_ROUTER
- AGNI_POSITION_MANAGER
- AGNI_QUOTER
- AAVE_V3_POOL
- AAVE_V3_POOL_ADDRESSES_PROVIDER
```

Run: `jq -e '.contracts[] | select(.key=="AAVE_V3_POOL")' mantle-address-registry-navigator/assets/registry.json`
Expected: non-zero exit because the key does not exist yet

**Step 2: Add minimal registry metadata and curated protocol entries**

Update `mantle-address-registry-navigator/assets/registry.json` to:

- bump `schema_version` from `1.0.0` to `1.1.0`
- replace the template-only body with real verified `defi` entries
- add optional DeFi metadata fields used by `mantle-defi-operator`

Use this entry shape for each curated contract:

```json
{
  "key": "MERCHANT_MOE_ROUTER",
  "label": "Merchant Moe Router",
  "environment": "mainnet",
  "category": "defi",
  "address": "REPLACE_WITH_EIP55_CHECKSUM_ADDRESS",
  "status": "active",
  "is_official": true,
  "aliases": ["MoeRouter", "merchant_moe_router"],
  "protocol_id": "merchant_moe",
  "contract_role": "router",
  "supports": ["swap", "add_liquidity", "remove_liquidity"],
  "source": {
    "url": "https://docs.merchantmoe.com/resources/contracts",
    "retrieved_at": "REPLACE_WITH_CURRENT_UTC_TIMESTAMP"
  },
  "notes": "Curated Tier 1 DEX default on Mantle."
}
```

Seed the first pass with:

- `Merchant Moe` official contracts from `https://docs.merchantmoe.com/resources/contracts`
- `Aave v3` official Mantle addresses from the Aave address book / `search.onaave.com`
- `Agni` official addresses from Agni’s official docs or app-linked verified contract sources; if no official docs page exists, use the verified contract pages linked from the official app and document that provenance explicitly

**Step 3: Update the registry playbook and skill docs**

Update `mantle-address-registry-navigator/references/address-registry-playbook.md` to document these optional fields:

- `protocol_id`
- `contract_role`
- `supports`

Update `mantle-address-registry-navigator/SKILL.md` so local fallback guidance explicitly supports DeFi protocol contract lookups by registry key and role.

**Step 4: Run registry validation**

Run: `python3 -m json.tool mantle-address-registry-navigator/assets/registry.json >/dev/null`
Expected: exit 0

Run: `jq -e '.contracts[] | select(.key=="MERCHANT_MOE_ROUTER" and .protocol_id=="merchant_moe" and .contract_role=="router")' mantle-address-registry-navigator/assets/registry.json >/dev/null`
Expected: exit 0

Run: `jq -e '.contracts[] | select(.key=="AAVE_V3_POOL" and .protocol_id=="aave_v3")' mantle-address-registry-navigator/assets/registry.json >/dev/null`
Expected: exit 0

**Step 5: Commit the registry work**

```bash
git add mantle-address-registry-navigator/assets/registry.json mantle-address-registry-navigator/references/address-registry-playbook.md mantle-address-registry-navigator/SKILL.md docs/skill-tests/2026-03-08-mantle-defi-operator-discovery.md
git commit -m "feat: add curated mantle defi protocol registry entries"
```

### Task 3: Add Curated Defaults and Selection Policy Files

**Files:**
- Create: `mantle-defi-operator/references/curated-defaults.yaml`
- Create: `mantle-defi-operator/references/protocol-selection-policy.md`
- Test: `mantle-defi-operator/references/curated-defaults.yaml`
- Test: `mantle-defi-operator/references/protocol-selection-policy.md`

**Step 1: Write the failing file-existence checks**

Run: `test -f mantle-defi-operator/references/curated-defaults.yaml`
Expected: exit 1

Run: `test -f mantle-defi-operator/references/protocol-selection-policy.md`
Expected: exit 1

**Step 2: Create `curated-defaults.yaml`**

Create `mantle-defi-operator/references/curated-defaults.yaml` with this exact starting content:

```yaml
swap_defaults:
  - merchant_moe
  - agni
liquidity_defaults:
  - merchant_moe
  - agni
lending_defaults:
  - aave_v3
selection_policy:
  prefer_curated_when_score_delta_bps: 150
  stale_metrics_max_age_hours: 24
  stale_verification_max_age_days: 30
  discovery_source_label: DefiLlama
```

**Step 3: Create `protocol-selection-policy.md`**

Create `mantle-defi-operator/references/protocol-selection-policy.md` with these sections:

```markdown
# Protocol Selection Policy

## Candidate gating

- Only recommend protocols whose contract addresses resolve from `mantle-address-registry-navigator`.
- Ignore discovery-only protocols for execution-ready guidance.
- Block recommendations when required contract roles are missing.

## Ranking signals

### Swaps
- quote quality
- recent volume
- pool depth
- slippage risk

### Liquidity
- TVL
- recent volume
- pool fit
- operational complexity

### Lending
- TVL
- utilization
- asset support
- withdrawal liquidity

## Fallbacks

- If live metrics are unavailable, fall back to curated default order.
- If the score delta is small, keep the curated default first.
- If the user names another protocol, verify it before comparing it.

## Discovery messaging

- Mention `DefiLlama` for broader ecosystem discovery.
- Do not treat `DefiLlama` as a contract-truth source.
```

**Step 4: Validate the new reference files**

Run: `rg -n "swap_defaults:|lending_defaults:|selection_policy:|DefiLlama" mantle-defi-operator/references/curated-defaults.yaml mantle-defi-operator/references/protocol-selection-policy.md`
Expected: matching lines in both files

**Step 5: Commit the reference files**

```bash
git add mantle-defi-operator/references/curated-defaults.yaml mantle-defi-operator/references/protocol-selection-policy.md
git commit -m "feat: add curated defaults and protocol selection policy"
```

### Task 4: Update `mantle-defi-operator` to Use Curated Discovery

**Files:**
- Modify: `mantle-defi-operator/SKILL.md`
- Modify: `mantle-defi-operator/agents/openai.yaml`
- Modify: `mantle-defi-operator/references/swap-sop.md`
- Modify: `mantle-defi-operator/references/liquidity-sop.md`
- Modify: `mantle-defi-operator/references/defi-execution-guardrails.md`
- Test: `mantle-defi-operator/SKILL.md`

**Step 1: Write the failing text checks**

Run: `rg -n "curated defaults|DefiLlama|recommended|also_viable|data_freshness|confidence|registry key" mantle-defi-operator/SKILL.md`
Expected: no matches

**Step 2: Update the main skill workflow**

Modify `mantle-defi-operator/SKILL.md` so the workflow explicitly does all of the following:

- resolves protocol contracts from `mantle-address-registry-navigator`
- prefers Tier 1 curated defaults (`Merchant Moe`, `Agni`, `Aave v3`)
- ranks eligible candidates with live volume / TVL / liquidity signals
- distinguishes `recommended`, `also_viable`, and `discovery_only`
- blocks execution planning when contracts are unknown or unverified

Update the output format to include:

```text
Protocol Selection
- recommended:
- also_viable:
- discovery_only:
- rationale:
- data_freshness:
- confidence:
```

**Step 3: Update supporting references**

Modify `mantle-defi-operator/references/swap-sop.md` to add a protocol-selection step before quote resolution.

Modify `mantle-defi-operator/references/liquidity-sop.md` to add candidate-pool selection and ranking guidance.

Modify `mantle-defi-operator/references/defi-execution-guardrails.md` to state that:

- execution-ready contracts must come from the shared registry
- discovery-only protocols may be mentioned without being execution targets
- live metrics can influence ranking but not address trust

Update `mantle-defi-operator/agents/openai.yaml` so the UI description mentions curated Mantle DeFi recommendations.

**Step 4: Validate the updated skill text**

Run: `rg -n "Merchant Moe|Agni|Aave v3|DefiLlama|also_viable|discovery_only|data_freshness|confidence" mantle-defi-operator/SKILL.md mantle-defi-operator/references/*.md mantle-defi-operator/agents/openai.yaml`
Expected: matching lines in the modified files

**Step 5: Commit the operator changes**

```bash
git add mantle-defi-operator/SKILL.md mantle-defi-operator/agents/openai.yaml mantle-defi-operator/references/swap-sop.md mantle-defi-operator/references/liquidity-sop.md mantle-defi-operator/references/defi-execution-guardrails.md
git commit -m "feat: add curated discovery workflow to mantle defi operator"
```

### Task 5: Run GREEN Verification on Skill Behavior

**Files:**
- Modify: `docs/skill-tests/2026-03-08-mantle-defi-operator-discovery.md`
- Test: `mantle-defi-operator/SKILL.md`
- Test: `mantle-address-registry-navigator/assets/registry.json`

**Step 1: Re-run the structural checks**

Run: `python3 -m json.tool mantle-address-registry-navigator/assets/registry.json >/dev/null && rg -n "Merchant Moe|Agni|Aave v3|DefiLlama|also_viable|discovery_only" mantle-defi-operator/SKILL.md mantle-defi-operator/references/*.md`
Expected: exit 0 and matching lines

**Step 2: Re-run the pressure scenarios**

Use a fresh agent session and replay the three prompts from `docs/skill-tests/2026-03-08-mantle-defi-operator-discovery.md`.

Expected outcomes:

- Scenario 1 recommends `Merchant Moe` or `Agni` from curated defaults with verified contract references
- Scenario 2 recommends `Aave v3` first for lending
- Scenario 3 points to `DefiLlama` for additional exploration without inventing addresses

**Step 3: Record GREEN results**

Append a `## GREEN Verification` section to `docs/skill-tests/2026-03-08-mantle-defi-operator-discovery.md` with:

- the prompts used
- a short pass/fail note for each
- any loopholes or ambiguous behavior observed

**Step 4: Refactor only if a loophole appears**

If the skill still:

- recommends unverified addresses
- skips curated defaults
- over-trusts discovery data

then make the minimal wording fix in the relevant skill/reference file and re-run Step 1 and Step 2.

**Step 5: Commit verification**

```bash
git add docs/skill-tests/2026-03-08-mantle-defi-operator-discovery.md mantle-defi-operator/SKILL.md mantle-defi-operator/references/*.md mantle-address-registry-navigator/assets/registry.json
git commit -m "test: verify curated discovery behavior for mantle skills"
```

### Task 6: Final Review and Handoff

**Files:**
- Modify: `docs/plans/2026-03-08-mantle-defi-operator-discovery-registry-design.md`
- Test: `docs/plans/2026-03-08-mantle-defi-operator-discovery-registry-implementation.md`

**Step 1: Add implementation status back to the design doc**

Append a short `## Implementation Notes` section to `docs/plans/2026-03-08-mantle-defi-operator-discovery-registry-design.md` listing:

- the shared-registry decision
- the curated protocol set
- the location of the implementation plan

**Step 2: Sanity-check the plan document**

Run: `rg -n "^### Task |^\\*\\*Step [0-9]+:" docs/plans/2026-03-08-mantle-defi-operator-discovery-registry-implementation.md`
Expected: six tasks with numbered steps

**Step 3: Commit the handoff doc**

```bash
git add docs/plans/2026-03-08-mantle-defi-operator-discovery-registry-design.md docs/plans/2026-03-08-mantle-defi-operator-discovery-registry-implementation.md
git commit -m "docs: add mantle defi operator discovery implementation plan"
```
