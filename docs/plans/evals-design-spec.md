# Mantle Skills Eval Suite -- Design Spec

## Context

[ethskills-evals](https://github.com/nickshanks347/ethskills-evals) is a minimal, shell-based eval suite (bash + curl + jq + yq) that measures whether loading an ethskill improves model accuracy on Ethereum knowledge. It fetches skills from URLs, runs A/B tests (with skill vs bare model), and has a judge LLM grade responses.

This repo (`mantle-skills`) contains 10 curated agent skills for the Mantle network. These skills mix factual knowledge (chain IDs, addresses, protocols) with procedural guidance (DeFi workflows, risk evaluation, debugging). They live as local files with rich reference subdirectories -- not hosted at a URL.

This design adapts the ethskills-evals pattern for mantle-skills, integrated directly into this repo, accounting for:

- **In-repo integration**: Evals live alongside the skills they test, so skill edits and eval updates stay in sync
- **Local skill loading**: Skills are repo-local `.md` files with `references/` subdirectories, not fetched from URLs
- **Reference bundling**: Many skills depend on reference files (registry.json, curated-defaults.yaml, SOPs) that must be loaded alongside SKILL.md
- **Procedural evals**: Some skills teach process/workflow, not just facts -- evals must test procedural correctness and fail-closed safety

---

## 1. Project Structure

New directories added to the repo:

```
mantle-skills/
  skills/                          # (existing) skill definitions
  docs/                            # (existing) design notes, reviews, tests
    plans/
      evals-design-spec.md        # This design doc
  evals/                           # (NEW) one YAML per skill
    network-primer.yaml
    address-registry.yaml
    risk-evaluator.yaml
    portfolio-analyst.yaml
    data-indexer.yaml
    readonly-debugger.yaml
    tx-simulator.yaml
    defi-operator.yaml
    smart-contract-developer.yaml
    smart-contract-deployer.yaml
  runner/                          # (NEW) eval execution
    run.sh                         # Main runner (forked from ethskills-evals, adapted)
    judge.md                       # Judge LLM system prompt (Mantle-adapted)
    load-skill.sh                  # Helper: bundles SKILL.md + references into one context
  results/                         # (NEW) benchmark outputs (gitignored except .gitkeep)
    .gitkeep
```

This keeps evals co-located with the skills they test. When a skill changes, the corresponding eval YAML is right there in the same repo.

---

## 2. Eval YAML Format

Extends the ethskills format with `skill_path` and `reference_paths` instead of `skill_url`:

```yaml
skill: mantle-network-primer
skill_path: skills/mantle-network-primer/SKILL.md
reference_paths:
  - skills/mantle-network-primer/references/mantle-network-basics.md
description: "Mantle network fundamentals, chain settings, and developer onboarding"

evals:
  - id: primer-gas-token
    prompt: "What token do I need to pay gas on Mantle?"
    expected_facts:
      - "MNT is the gas token on Mantle"
      - "NOT ETH -- developers must fund wallets with MNT"
    fail_if:
      - "Says gas is paid in ETH on Mantle"
      - "Does not mention MNT"
```

**Key fields**:

- `skill_path`: Relative path from the repo root (`mantle-skills/`) to the skill's SKILL.md
- `reference_paths`: List of reference/asset files (relative to repo root) to bundle with the skill content
- `evals[].id`, `evals[].prompt`, `evals[].expected_facts`, `evals[].fail_if`: Same semantics as ethskills-evals

---

## 3. Runner Adaptations

### 3.1 Skill Loading (`load-skill.sh`)

New helper script that bundles local skill content:

```
load-skill.sh <skill_path> [reference_path...]
```

Output: concatenated content with section headers:

```
--- SKILL ---
<SKILL.md content>
--- END SKILL ---

--- REFERENCE: mantle-network-basics.md ---
<file content>
--- END REFERENCE ---
```

### 3.2 Runner Changes from ethskills-evals

The runner (`run.sh`) is forked from `ethskills-evals/runner/run.sh` with these changes:

- Replace `curl -sL "$skill_url"` with `bash load-skill.sh "$skill_path" $reference_paths`
- Read `skill_path` and `reference_paths` from YAML using `yq` instead of `skill_url`
- Resolve all paths relative to the repo root (runner detects its own location via `SCRIPT_DIR` and navigates to `..`)
- Keep everything else identical: same API resolution, same chat_completion function, same judge flow, same results format

### 3.3 System prompt for "with skill" variant

```
You are a helpful AI assistant specializing in the Mantle network ecosystem.
Use the following reference material to answer the question.

--- REFERENCE ---
{bundled skill + references content}
--- END REFERENCE ---
```

---

## 4. Judge Prompt Adaptations

Fork `ethskills-evals/runner/judge.md` with these changes:

- Replace "ethskills.com -- a knowledge base that corrects stale AI training data about Ethereum" with "mantle-skills -- a curated skill set for Mantle network agent operations"
- Add Mantle-specific scoring guidance:
  - **Address accuracy is strict**: Contract addresses must be exact (no partial match, no 2x tolerance)
  - **Safety posture matters**: If the skill says "fail closed" / "block if unknown", the model must do the same
  - **Procedural correctness**: For workflow skills, check that steps are in the correct order and mandatory steps are not skipped
  - **Scope awareness**: If the model claims capability that the skill explicitly says is unavailable (e.g., tx simulation in mantle-mcp v0.2), that is a FAIL
- Keep the same verdict schema: `PASS` / `PARTIAL` / `FAIL` with `expected_hits`, `expected_misses`, `fail_triggers`, `reasoning`

---

## 5. Eval Definitions Per Skill

### 5.1 `network-primer.yaml` (9 evals) -- Factual/Reference

Tests whether models get Mantle fundamentals right.

| ID | Prompt (summary) | Key expected facts | Key fail conditions |
|----|-------------------|--------------------|---------------------|
| `primer-gas-token` | What token for gas on Mantle? | MNT, not ETH | Says ETH |
| `primer-chain-id` | What is Mantle mainnet chain ID? | 5000 (testnet: 5003) | Wrong chain ID |
| `primer-rpc-endpoint` | What RPC endpoint for Mantle mainnet? | `https://rpc.mantle.xyz` | Hallucinated URL |
| `primer-settlement-vs-inclusion` | Is a Mantle tx final once included in L2 block? | No -- inclusion != L1-backed settlement finality | Says L2 inclusion is final |
| `primer-wrapped-mnt` | What is the WMNT address on mainnet? | `0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8` | Wrong address |
| `primer-public-rpc-production` | Can I use the public Mantle RPC in production? | Rate-limited, use dedicated provider for production | Says public RPC is fine for production |
| `primer-architecture` | What is Mantle's architecture? | L2 execution, ZK validity proving, Ethereum DA via blobs (Mantle v2 Skadi) | Claims it's a sidechain or L1 |
| `primer-da-layer` | What is Mantle's data availability layer? | Ethereum blobs (EIP-4844); Mantle v2 Skadi uses Ethereum for DA | Claims Mantle uses its own DA or a third-party DA solution like Celestia |
| `primer-bridge` | How do I bridge assets to Mantle? | Official bridge at `https://app.mantle.xyz/bridge` | Hallucinated bridge URL |

### 5.2 `address-registry.yaml` (8 evals) -- Factual/Safety

Tests address resolution accuracy and anti-hallucination.

| ID | Prompt (summary) | Key expected facts | Key fail conditions |
|----|-------------------|--------------------|---------------------|
| `addr-merchant-moe-router` | Merchant Moe router address on Mantle? | `0xeaEE7EE68874218c3558b40063c42B82D3E7232a` | Wrong address or hallucinated |
| `addr-agni-router` | Agni router address? | `0x319B69888b0d11cEC22caA5034e25FfFBDc88421` | Wrong address |
| `addr-aave-v3-pool` | Aave v3 pool address on Mantle? | `0x458F293454fE0d67EC0655f3672301301DD51422` | Wrong address |
| `addr-unknown-protocol` | What is the router address for SushiSwap on Mantle? | Should say unknown/unverified, not guess | Provides a fabricated address |
| `addr-resolution-order` | How should I resolve a token address on Mantle? | MCP tool first, then registry fallback, block if nothing matches | Suggests using Etherscan or guessing |
| `addr-checksum-validation` | Given an invalid checksum address, what should happen? | Fail validation, do not proceed | Proceeds with invalid address |
| `addr-environment-match` | Can I use a testnet contract address on mainnet? | No -- environment must match, mainnet vs sepolia | Says it's fine to reuse across networks |
| `addr-agni-quoter` | Agni quoter address? | `0xc4aaDc921E1cdb66c5300Bc158a313292923C0cb` | Wrong address |

### 5.3 `risk-evaluator.yaml` (8 evals) -- Procedural/Safety

Tests risk assessment thresholds and fail-closed behavior.

| ID | Prompt (summary) | Key expected facts | Key fail conditions |
|----|-------------------|--------------------|---------------------|
| `risk-high-slippage` | Swap with 3% slippage -- safe? | Block: exceeds 1.0% threshold | Says 3% is acceptable |
| `risk-moderate-slippage` | Swap with 0.7% slippage? | Warn: between 0.5% and 1.0% | Says it's fine with no warning |
| `risk-infinite-approval` | Approve type(uint256).max? | Block: raw >= 2^255 is near-unlimited | Says unlimited approval is fine |
| `risk-missing-inputs` | Evaluate risk without specifying token or amount? | Block: mandatory inputs missing | Proceeds without required data |
| `risk-stale-deadline` | Transaction with 2-hour deadline? | Block: exceeds 60-minute fail threshold | Says 2 hours is reasonable |
| `risk-price-impact` | 4% price impact on a swap? | Warn: between 2% and 5% | No warning issued |
| `risk-gas-deviation` | Estimated gas is 50% higher than expected? | Block: exceeds 40% deviation threshold | Says it's normal |
| `risk-verdict-format` | What verdicts can the risk evaluator return? | `pass`, `warn`, `block` | Different verdict set |

### 5.4 `defi-operator.yaml` (10 evals) -- Procedural/Operational

Tests DeFi workflow correctness and protocol selection.

| ID | Prompt (summary) | Key expected facts | Key fail conditions |
|----|-------------------|--------------------|---------------------|
| `defi-swap-default-venue` | Where should I swap tokens on Mantle? | Start with Merchant Moe and Agni (tier 1 curated) | Recommends unverified DEX |
| `defi-lending-default` | Where to lend on Mantle? | Aave v3 is the curated lending default | Recommends a non-existent lending protocol |
| `defi-execution-readiness` | Can the DeFi operator execute a swap for me? | No -- mantle-mcp v0.2 is read-only; no signing or broadcasting | Claims it can execute |
| `defi-discovery-vs-execution` | What are the DeFi operator modes? | `discovery_only`, `compare_only`, `execution_ready` | Doesn't distinguish modes |
| `defi-defillama-trust` | Can I use DefiLlama data for contract addresses? | No -- DefiLlama is for discovery/metrics only, not contract truth | Uses DefiLlama addresses directly |
| `defi-supporting-skills` | What other skills does the DeFi operator depend on? | address-registry-navigator, risk-evaluator, portfolio-analyst | Claims it's self-contained |
| `defi-stale-metrics` | How old can DeFi metrics be before they're stale? | 24 hours max (stale_metrics_max_age_hours) | No staleness check |
| `defi-curated-score-delta` | When should I prefer a curated protocol over a discovered one? | When score delta is within 150 bps | No preference logic |
| `defi-swap-flow` | Walk me through a Mantle token swap | Resolve addresses (registry), check risk, compare venues, present plan | Skips address resolution or risk check |
| `defi-liquidity-flow` | How do I provide liquidity on Mantle? | Start with Merchant Moe/Agni, resolve via address registry, run risk evaluation | Skips risk evaluation |

### 5.5 `portfolio-analyst.yaml` (6 evals) -- Operational

| ID | Prompt (summary) | Key expected facts | Key fail conditions |
|----|-------------------|--------------------|---------------------|
| `portfolio-balance-query` | How to check wallet balance on Mantle? | `mantle_getBalance` and `mantle_getTokenBalances` MCP tools | Fabricates a different API |
| `portfolio-allowance-risk-critical` | What makes an allowance "critical" risk? | `is_unlimited=true` or allowance >= 2^255 | Wrong threshold |
| `portfolio-allowance-risk-levels` | What are the allowance risk levels? | low, medium, high, critical | Different classification |
| `portfolio-network-scope` | What networks does the portfolio analyst support? | `mainnet` and `sepolia` | Claims other networks |
| `portfolio-chain-info` | How to get Mantle chain status? | `mantle_getChainInfo` and `mantle_getChainStatus` tools | Fabricated tool names |
| `portfolio-address-validation` | How to validate an address before querying? | `mantle_validateAddress` tool; checksum and non-zero | No validation step |

### 5.6 `data-indexer.yaml` (6 evals) -- Operational

| ID | Prompt (summary) | Key expected facts | Key fail conditions |
|----|-------------------|--------------------|---------------------|
| `indexer-query-types` | What query methods are available? | GraphQL (`mantle_querySubgraph`) and SQL (`mantle_queryIndexerSql`) | Fabricated methods |
| `indexer-chain-id-sql` | What chain ID in SQL queries for Mantle mainnet? | 5000 | Wrong chain ID |
| `indexer-endpoint-fabrication` | What subgraph endpoint should I use? | Endpoints are runtime inputs, never fabricate | Provides a made-up URL |
| `indexer-no-data-vs-failure` | How to distinguish "no data" from "query failure"? | Different error handling for each; skill explicitly requires this distinction | Treats them the same |
| `indexer-wallet-activity` | How to get historical wallet swap activity? | GraphQL wallet swaps template with address filter | Fabricated query |
| `indexer-pool-volume` | How to find top pools by 24h volume? | SQL query template with chain_id=5000 | Wrong approach |

### 5.7 `readonly-debugger.yaml` (6 evals) -- Procedural

| ID | Prompt (summary) | Key expected facts | Key fail conditions |
|----|-------------------|--------------------|---------------------|
| `debug-rpc-timeout` | RPC call times out -- what to do? | Transport-layer error; retry with backoff, check endpoint health | Claims it's a contract error |
| `debug-429-error` | Getting 429 errors from Mantle RPC | Rate limiting; use dedicated provider for production | Says to increase gas |
| `debug-quote-revert` | Quote call returns null/error | Quote failure; check token pair, path availability, liquidity | Claims transaction failed |
| `debug-balance-mismatch` | Balance differs between calls | Possible pending txs or nonce issues; compare across blocks | Ignores the discrepancy |
| `debug-execution-reverted` | "execution reverted" error | Call/revert error; decode revert reason, check inputs and state | Generic "try again" advice |
| `debug-escalation` | When should debugging be escalated? | When root cause is unresolved after playbook steps; prepare escalation package | Never escalates |

### 5.8 `tx-simulator.yaml` (6 evals) -- Procedural/Safety

| ID | Prompt (summary) | Key expected facts | Key fail conditions |
|----|-------------------|--------------------|---------------------|
| `sim-mcp-capability` | Can mantle-mcp simulate transactions? | No -- mantle-mcp v0.2 has no tx simulation tool; must use external backends | Claims mantle-mcp can simulate |
| `sim-backends` | What simulation backends are available? | Local fork (Anvil) and managed API (Tenderly) | Fabricates a backend |
| `sim-inconclusive` | When is a simulation inconclusive? | Backend error, unresolved calldata, missing token metadata | Claims simulations are always conclusive |
| `sim-wysiwys` | What is WYSIWYS? | "What You See Is What You Sign" -- human-readable tx explanation before signing | Doesn't know the concept |
| `sim-revert-analysis` | Simulation shows a revert -- what to do? | Decode revert reason, check state diffs, explain in plain language | Just says "fix the contract" |
| `sim-pre-signing` | When should simulation happen relative to signing? | Always before signing, never after | Says simulation is optional |

### 5.9 `smart-contract-developer.yaml` (6 evals) -- Procedural

| ID | Prompt (summary) | Key expected facts | Key fail conditions |
|----|-------------------|--------------------|---------------------|
| `dev-gas-token-check` | What must I confirm about gas before deploying on Mantle? | Confirm MNT for gas, not ETH | Assumes ETH |
| `dev-solidity-version` | Recommended Solidity version for Mantle? | v0.8.23 or below | Claims latest Solidity works without caveats |
| `dev-oz-handoff` | When to use OpenZeppelin MCP? | Scaffolding, inheritance, security patterns, access control | Never mentions OZ MCP |
| `dev-address-verification` | How to verify protocol addresses for integration? | Environment-correct addresses from registry; check L1/L2 system contract docs | Uses unverified addresses |
| `dev-upgradeability` | Should contracts be upgradeable? | Depends on use case; skill covers proxy patterns and access control | Always yes or always no |
| `dev-mantle-specific-checks` | What Mantle-specific integration checks are needed? | MNT gas funding, correct chain ID, environment-matched addresses, system contract compatibility | None mentioned |

### 5.10 `smart-contract-deployer.yaml` (6 evals) -- Procedural

| ID | Prompt (summary) | Key expected facts | Key fail conditions |
|----|-------------------|--------------------|---------------------|
| `deploy-checklist` | What do I need before deploying on Mantle? | Environment, chain ID, RPC, compiler, optimizer, constructor args | Missing critical items |
| `deploy-verification` | How to verify a contract on Mantle explorer? | Submit source + compiler settings to Mantlescan; common issues: compiler version, optimizer, constructor args | Wrong verification flow |
| `deploy-signer-handoff` | Who signs deployment transactions? | External signer handoff -- the skill does not sign | Claims the agent signs |
| `deploy-receipt-capture` | What should I capture after deployment? | Transaction receipt, contract address, block number | Only contract address |
| `deploy-explorer-url` | What explorer for Mantle mainnet? | `https://mantlescan.xyz/` | Wrong URL |
| `deploy-after-developer` | What must be complete before deployment? | Architecture and implementation from mantle-smart-contract-developer skill | No prerequisites mentioned |

---

## 6. Eval Count Summary

| Skill | Eval Count | Type |
|-------|-----------|------|
| network-primer | 9 | Factual/Reference |
| address-registry | 8 | Factual/Safety |
| risk-evaluator | 8 | Procedural/Safety |
| defi-operator | 10 | Procedural/Operational |
| portfolio-analyst | 6 | Operational |
| data-indexer | 6 | Operational |
| readonly-debugger | 6 | Procedural |
| tx-simulator | 6 | Procedural/Safety |
| smart-contract-developer | 6 | Procedural |
| smart-contract-deployer | 6 | Procedural |
| **Total** | **71** | |

---

## 7. Design Decisions

### Why integrate into mantle-skills instead of a separate repo?

Skill edits and eval updates should stay in sync. When someone changes a skill, the eval YAML is right next to it in the same commit. A separate repo creates drift -- evals lag behind skill changes and nobody notices until the next eval run.

### Why fork the runner instead of generalizing ethskills-evals?

The ethskills runner is 260 lines of bash. Making it generic enough to handle both URL-fetched and local-file skills adds complexity for minimal reuse gain. A clean fork with local-loading is simpler and lets each eval suite evolve independently.

### Why bundle references?

Mantle skills are designed to be loaded with their reference material. The address registry navigator is nearly useless without `registry.json`. The DeFi operator needs `curated-defaults.yaml`. Bundling references into the skill context matches how agents actually use these skills.

### Procedural evals vs factual evals

Ethskills evals are mostly factual ("what is the gas price?"). Mantle skills include procedural guidance ("what should the risk evaluator do given X?"). The judge prompt is adapted to evaluate procedural correctness: correct step ordering, mandatory step inclusion, and fail-closed safety.

---

## 8. Implementation Checklist

- [ ] Create `evals/`, `runner/`, `results/` directories inside `mantle-skills/`
- [ ] Write `runner/load-skill.sh` helper to bundle SKILL.md + reference files into one context string
- [ ] Fork `ethskills-evals/runner/run.sh` and adapt skill loading to use repo-local paths and `load-skill.sh`
- [ ] Fork `ethskills-evals/runner/judge.md` and add Mantle-specific scoring rules (address exactness, safety posture, procedural order, scope claims)
- [ ] Write `evals/network-primer.yaml` (9 evals: gas token, chain ID, RPC, settlement, WMNT, public RPC, architecture, DA layer, bridge)
- [ ] Write `evals/address-registry.yaml` (8 evals: Merchant Moe, Agni, Aave v3 addresses, unknown protocol, resolution order, checksum, env match)
- [ ] Write `evals/risk-evaluator.yaml` (8 evals: slippage thresholds, infinite approval, missing inputs, deadline, price impact, gas deviation, verdicts)
- [ ] Write `evals/defi-operator.yaml` (10 evals: default venues, lending, execution readiness, modes, DefiLlama trust, supporting skills, staleness, swap/liquidity flows)
- [ ] Write `evals/portfolio-analyst.yaml` (6 evals: balance query, allowance risk, risk levels, network scope, chain tools, address validation)
- [ ] Write `evals/data-indexer.yaml` (6 evals: query types, chain ID, endpoint fabrication, no-data vs failure, wallet activity, pool volume)
- [ ] Write `evals/readonly-debugger.yaml` (6 evals: RPC timeout, 429 errors, quote revert, balance mismatch, execution reverted, escalation)
- [ ] Write `evals/tx-simulator.yaml` (6 evals: MCP capability, backends, inconclusive, WYSIWYS, revert analysis, pre-signing)
- [ ] Write `evals/smart-contract-developer.yaml` (6 evals: gas token, Solidity version, OZ handoff, address verification, upgradeability, Mantle-specific checks)
- [ ] Write `evals/smart-contract-deployer.yaml` (6 evals: checklist, verification, signer handoff, receipt capture, explorer URL, prerequisites)
- [ ] Add an "Evals" section to the existing `README.md`
- [ ] Update `.gitignore` to exclude `results/*.json`
- [ ] Test with: `./runner/run.sh --skill network-primer --model openai/gpt-5.2`
- [ ] Do NOT modify any existing `skills/`, `docs/skill-tests/`, or `docs/skills-review-*.md` files
