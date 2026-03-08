# Mantle DeFi Operator Discovery + Registry Design

Date: 2026-03-08
Status: Approved for planning

## Summary

Extend `mantle-defi-operator` with a discovery layer that:

- promotes a small set of curated Mantle DeFi defaults
- maintains a local verified registry of protocol contracts
- uses live market metrics to rank protocol suggestions during analysis
- points users to external discovery surfaces such as DefiLlama for broader ecosystem exploration

This keeps execution guidance deterministic and reviewable while still allowing recommendations to adapt to current liquidity conditions.

## Goals

- Provide first-class support for mainstream Mantle protocols:
  - `Merchant Moe`
  - `Agni`
  - `Aave v3`
- Let the skill actively suggest protocols during swap, liquidity, and lending planning.
- Ensure all recommended contracts come from a local verified registry, not ad hoc page scraping.
- Use live daily volume / TVL style metrics to influence recommendation order.
- Preserve current guardrails around address verification and read-only execution planning.

## Non-Goals

- Hardcode market metrics such as TVL or daily volume into the skill.
- Treat external analytics sites as contract-truth sources.
- Expand into transaction execution, signing, or broadcasting.
- Support every Mantle protocol in the first iteration.

## Product Model

The skill uses a three-level discovery model.

### Tier 1: Curated Defaults

These are the protocols actively promoted by the skill and preferred first when they fit the requested operation:

- DEX: `Merchant Moe`, `Agni`
- Lending: `Aave v3`

These defaults should feel opinionated, safe, and easy to understand.

### Tier 2: Allowlisted Ecosystem

Additional Mantle protocols may be stored in the local registry and considered when:

- they support the requested action
- they have verified Mantle contract metadata
- they outperform a curated default for the specific use case

Tier 2 protocols are available but not highlighted as the default experience.

### Tier 3: Open Discovery

The skill can mention that users or developers may discover more protocols through sources like `DefiLlama`, but those sources are for discovery and comparative metrics only, not contract truth.

## Source of Truth Strategy

The design uses a hybrid model.

### Local Contract Truth

Maintain protocol contract addresses locally in versioned registry files. Each entry must carry provenance fields such as:

- source URL
- source type
- verified at timestamp
- confidence / verification state

This makes protocol selection deterministic and compatible with the current guardrail that rejects unknown or unverified token/router/pool addresses.

### Live Market Truth

Fetch changing signals such as:

- TVL
- recent volume
- pool depth
- quote quality

at analysis time from external market-data sources. These values influence ranking, but do not replace local contract verification.

## Proposed Data Files

### `mantle-defi-operator/references/protocol-registry.yaml`

Stores all known Mantle protocol metadata and verified contracts.

Suggested structure per protocol:

- `protocol_id`
- `display_name`
- `category`
- `mantle_status` (`curated`, `allowlisted`, `experimental`)
- `supports`
- `contracts`
- `official_links`
- `sources`
- `risk_notes`

Suggested contract roles include:

- `router`
- `factory`
- `quoter`
- `position_manager`
- `pool_manager`
- `lending_pool`
- `pool`
- `vault`

### `mantle-defi-operator/references/curated-defaults.yaml`

Stores preferred protocol ordering by operation type.

Suggested structure:

- `swap_defaults`
- `liquidity_defaults`
- `lending_defaults`
- `selection_policy`

Initial contents:

- swap defaults: `merchant_moe`, `agni`
- liquidity defaults: `merchant_moe`, `agni`
- lending defaults: `aave_v3`

## Recommendation Logic

The skill should recommend protocols in two passes.

### Pass 1: Safety Gate

Only keep candidates that satisfy all of the following:

- verified Mantle deployment exists in the local registry
- requested operation is supported
- required contract roles are present
- no blocking risk note applies
- source verification metadata is present and sufficiently fresh

If these checks fail, the protocol is not eligible for recommendation.

### Pass 2: Ranking

Rank eligible candidates using operation-specific signals.

For swaps:

- quote quality
- pool depth
- recent volume
- slippage risk
- gas / route complexity

For add/remove liquidity:

- TVL
- recent volume
- volume to TVL efficiency
- depth and pair fit
- operational complexity

For lending:

- TVL
- market support for the requested asset
- utilization and liquidity availability
- protocol fit for the requested action

The recommendation engine should be volume/TVL-aware, not volume/TVL-only.

## Output Model

The skill should return protocol selection results in a structured form such as:

- `recommended`
- `also_viable`
- `not_recommended`
- `why`
- `data_freshness`
- `confidence`

Every recommended protocol should include a concise explanation, for example:

- preferred curated default with verified router and strongest current liquidity for this pair
- allowlisted alternative with better current depth but lower curation priority

## Fallback and Error Rules

### Fallbacks

- If live metrics are unavailable, fall back to curated default ordering and clearly state that live metrics are stale or unavailable.
- If a curated protocol does not support the requested pair, pool, or market, skip it and explain why.
- If two candidates are close, prefer the curated default unless live execution quality is materially better elsewhere.
- If the user explicitly names another protocol, analyze it after verification and compare it against the default recommendation.

### Errors / Blocks

- Unknown protocol or address: reject as unverified.
- Conflicting addresses across sources: block recommendation until manually verified.
- Stale verification metadata: permit mention in exploratory context, but do not use for execution-ready guidance.
- Unverified but high-volume protocol discovered externally: mention as discovery only, not as a recommended execution target.

## Skill Behavior Changes

The updated skill should:

- suggest Tier 1 protocols first when the requested action fits
- compare alternatives using live metrics after registry verification
- preserve current read-only planning boundaries
- explicitly distinguish curated defaults from broader ecosystem discovery
- continue to reject unknown or unverified addresses in execution planning

## Content Governance

Registry entries should be manually curated and periodically reviewed.

Each protocol entry should record:

- who verified it
- when it was verified
- where it was verified from

This supports safe updates without forcing runtime scraping of protocol documentation.

## Open Implementation Questions

- Which live market-data source or sources should back TVL / volume scoring in the first implementation?
- What freshness window should mark verification metadata or live metrics as stale?
- Should lending ranking include incentives/APY in the first pass, or remain liquidity-first?

## Recommendation

Implement the hybrid model:

- local verified registry for contract truth
- curated defaults for product guidance
- live metrics for dynamic ranking
- external discovery references for broader ecosystem exploration

This is the safest and most maintainable way to make `mantle-defi-operator` feel opinionated, useful, and current without weakening its execution guardrails.

## Implementation Notes

- Shared registry decision: verified execution-ready contract addresses now live in `skills/mantle-address-registry-navigator/assets/registry.json`.
- Curated protocol set: `Merchant Moe`, `Agni`, and `Aave v3`.
- Implementation plan location: `docs/plans/2026-03-08-mantle-defi-operator-discovery-registry-implementation.md`.
