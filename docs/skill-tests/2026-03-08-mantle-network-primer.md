## RED Baseline

Command:

```bash
rg -n "differences|developer hints|rate-limited|public RPC|MNT.*gas|inclusion|L1-backed settlement" mantle-network-primer/SKILL.md mantle-network-primer/references/mantle-network-basics.md
```

Output:

```text
mantle-network-primer/SKILL.md:3:description: Explain Mantle network fundamentals for onboarding and comparison requests. Use when users ask what Mantle is, how Mantle differs from other L2s, why MNT is needed for gas, or how Mantle relates to Ethereum L1 settlement and finality.
mantle-network-primer/SKILL.md:25:- Distinguish transaction inclusion from final settlement.
mantle-network-primer/references/mantle-network-basics.md:65:- Mantle docs state official RPC endpoints are rate-limited for stability.
mantle-network-primer/references/mantle-network-basics.md:74:  - `inclusion`: transaction appears in L2 block.
mantle-network-primer/references/mantle-network-basics.md:75:  - `L1-backed settlement finality`: strongest settlement assurance once L1 conditions are satisfied.

```

Baseline note: The existing primer covers some settlement and MNT basics, but it lacks a dedicated Mantle-specific differences section, lacks a dedicated developer-hints section, and does not package the public-RPC guidance as a developer onboarding takeaway.

## GREEN Verification

Prompts:

- What is Mantle and what makes it different for developers?
- Why do I need MNT if Mantle is EVM-compatible?
- Can I use the public Mantle RPC in production?

Command:

```bash
rg -n "MNT|gas token|rate-limited|dedicated provider|inclusion|settlement|finality|Mantle-Specific Differences|Developer Hints|developer onboarding" mantle-network-primer/SKILL.md mantle-network-primer/references/mantle-network-basics.md mantle-network-primer/agents/openai.yaml
```

Output:

```text
mantle-network-primer/agents/openai.yaml:4:  default_prompt: "Use $mantle-network-primer to explain Mantle basics, MNT gas, settlement and finality, and Mantle-specific developer onboarding hints."
mantle-network-primer/SKILL.md:3:description: Explain Mantle network fundamentals and developer onboarding differences. Use when users ask what Mantle is, what is different about Mantle for developers, why MNT is needed for gas, or how Mantle L2 inclusion relates to Ethereum-backed settlement and finality.
mantle-network-primer/SKILL.md:24:   - gas is paid in `MNT`
mantle-network-primer/SKILL.md:25:   - L2 inclusion is not the same as L1-backed settlement/finality
mantle-network-primer/SKILL.md:26:   - public RPC endpoints are rate-limited
mantle-network-primer/SKILL.md:31:- Define key terms once: `sequencer`, `settlement`, `finality`, `gas token`.
mantle-network-primer/SKILL.md:32:- Distinguish transaction inclusion from final settlement.
mantle-network-primer/SKILL.md:42:`Mantle is an Ethereum-aligned Layer 2 execution network. Users transact on L2 and pay gas in MNT, while strongest settlement guarantees are tied to Ethereum L1.`
mantle-network-primer/SKILL.md:46:`What feels different about Mantle for developers is that gas is paid in MNT, onboarding requires Mantle-specific chain settings, and fast L2 inclusion should not be confused with Ethereum-backed settlement finality.`
mantle-network-primer/references/mantle-network-basics.md:20:- Gas on Mantle is paid in `MNT`.
mantle-network-primer/references/mantle-network-basics.md:22:## Mantle-Specific Differences
mantle-network-primer/references/mantle-network-basics.md:24:- `MNT` is the gas token, so developers should not assume `ETH`-funded wallets can transact on Mantle.
mantle-network-primer/references/mantle-network-basics.md:25:- Mantle is Ethereum-aligned, but fast L2 transaction inclusion is not the same thing as strongest L1-backed settlement/finality.
mantle-network-primer/references/mantle-network-basics.md:40:- Token symbol: `MNT`
mantle-network-primer/references/mantle-network-basics.md:48:- Token symbol: `MNT`
mantle-network-primer/references/mantle-network-basics.md:57:- Wrapped MNT: `0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8`
mantle-network-primer/references/mantle-network-basics.md:67:- Wrapped MNT: `0x19f5557E23e9914A18239990f6C70D68FDF0deD5`
mantle-network-primer/references/mantle-network-basics.md:68:- Note: Mantle docs indicate Sepolia MNT can be requested directly from faucet (subject to limits).
mantle-network-primer/references/mantle-network-basics.md:70:## Developer Hints
mantle-network-primer/references/mantle-network-basics.md:72:- Fund developer and test wallets with `MNT`, not `ETH`, before attempting transactions on Mantle.
mantle-network-primer/references/mantle-network-basics.md:75:- Official public RPC endpoints are suitable for onboarding and light usage, but production or high-frequency workloads should use dedicated providers.
mantle-network-primer/references/mantle-network-basics.md:78:  - `inclusion`: the transaction is visible in an L2 block
mantle-network-primer/references/mantle-network-basics.md:79:  - `L1-backed settlement finality`: the strongest settlement assurance once the L1-side conditions are satisfied
mantle-network-primer/references/mantle-network-basics.md:91:- Mantle docs state official RPC endpoints are rate-limited for stability.
mantle-network-primer/references/mantle-network-basics.md:92:- For high-frequency or production workloads, prefer dedicated provider endpoints.
mantle-network-primer/references/mantle-network-basics.md:98:- Treat throughput, fee levels, ecosystem counts, and latency/finality windows as volatile.
mantle-network-primer/references/mantle-network-basics.md:100:  - `inclusion`: transaction appears in L2 block.
mantle-network-primer/references/mantle-network-basics.md:101:  - `L1-backed settlement finality`: strongest settlement assurance once L1 conditions are satisfied.
mantle-network-primer/references/mantle-network-basics.md:110:1. gas token and wallet funding expectations
mantle-network-primer/references/mantle-network-basics.md:111:2. inclusion versus L1-backed settlement/finality

```

GREEN note: The updated primer now exposes Mantle-specific differences, developer onboarding hints, MNT gas-token guidance, settlement terminology, and production RPC caveats in directly retrievable sections.

## Positioning Verification

Command:

```bash
rg -n "reference/onboarding|misconception prevention|execution operator" \
  skills/mantle-network-primer/SKILL.md \
  skills/mantle-network-primer/agents/openai.yaml \
  skills/mantle-network-primer/references/mantle-network-basics.md \
  docs/skills-review-2026-03-08.md
```

Expected:

- The skill, agent metadata, and review note all describe `mantle-network-primer` as a reference/onboarding skill rather than a pure execution operator.
