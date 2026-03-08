# Mantle Network Primer Design

**Date:** March 8, 2026

**Goal:** Refocus `mantle-network-primer` so it teaches stable Mantle fundamentals, explicitly calls out Mantle-specific differences, and gives developers practical onboarding hints without relying on volatile cross-chain rankings.

## Approved Scope

- Keep the skill focused on Mantle only.
- Explain what Mantle is in stable, source-grounded terms.
- Clarify the differences that matter most for developers:
  - `MNT` is the gas token.
  - Mantle is Ethereum-aligned but not Ethereum-identical.
  - Users should distinguish fast L2 inclusion from stronger L1-backed settlement/finality.
  - Public RPC endpoints are rate-limited and are not the default recommendation for production.
  - Mantle-specific onboarding values such as chain IDs, bridge links, and compiler guidance belong in the reference.
- Avoid chain-by-chain comparisons and avoid volatile performance claims.

## Design Approach

Update the skill in three layers:

1. **Skill trigger and workflow**
   - Expand the description to mention developer onboarding and Mantle-specific operational differences.
   - Replace the old `comparison` emphasis with a `differences` framing that does not require named external chains.

2. **Reference grounding**
   - Refresh the snapshot date.
   - Add a dedicated `Mantle-specific differences` section.
   - Add a `Developer hints` section that packages the most useful operational guidance in one place.
   - Keep volatile metrics explicitly out of the stable reference.

3. **Agent metadata**
   - Tighten the display description and default prompt so the agent is discoverable for Mantle basics plus dev onboarding.

## Content Boundaries

- Do include:
  - Mantle network basics
  - Mantle-specific developer gotchas
  - Stable terminology definitions
  - Source-of-truth links
- Do not include:
  - live fee or throughput claims
  - ecosystem rankings
  - named rollup-vs-rollup comparisons unless future requirements ask for them

## Verification Plan

- Capture a small RED baseline showing the current skill lacks Mantle-specific difference and developer-hint phrasing.
- Patch the skill and reference.
- Run retrieval-style GREEN checks to confirm the updated files now expose:
  - `MNT` gas-token guidance
  - inclusion vs settlement wording
  - public RPC rate-limit guidance
  - Mantle-specific developer hints
