# Mantle Network Primer Improvements Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update `mantle-network-primer` so it teaches Mantle-specific differences and developer onboarding hints with stable, source-grounded wording.

**Architecture:** Keep the implementation lightweight and documentation-only. Strengthen the skill trigger text and workflow in `mantle-network-primer/SKILL.md`, expand the durable reference content in `mantle-network-primer/references/mantle-network-basics.md`, and align `mantle-network-primer/agents/openai.yaml` with the new scope.

**Tech Stack:** Markdown skill documents, YAML agent metadata, shell-based retrieval checks

---

### Task 1: Capture the failing baseline

**Files:**
- Create: `docs/skill-tests/2026-03-08-mantle-network-primer.md`
- Inspect: `mantle-network-primer/SKILL.md`
- Inspect: `mantle-network-primer/references/mantle-network-basics.md`

**Step 1: Write the failing acceptance checks**

The improved primer must expose all of the following:

- a Mantle-specific `differences` framing rather than named-chain comparison dependence
- explicit `MNT` gas-token guidance for developers
- explicit inclusion vs L1-backed settlement wording
- public RPC rate-limit guidance for production users
- a compact developer-hints section in the reference

**Step 2: Run baseline checks to verify the gaps**

Run:

```bash
rg -n "differences|developer hints|rate-limited|public RPC|MNT.*gas|inclusion|L1-backed settlement" mantle-network-primer/SKILL.md mantle-network-primer/references/mantle-network-basics.md
```

Expected:

- matches are incomplete or missing for the new scope, especially `developer hints` and a dedicated `differences` section

**Step 3: Record the baseline finding**

Append the command output and a short note to `docs/skill-tests/2026-03-08-mantle-network-primer.md` under `## RED Baseline`.

### Task 2: Update the Mantle primer skill and reference

**Files:**
- Modify: `mantle-network-primer/SKILL.md`
- Modify: `mantle-network-primer/references/mantle-network-basics.md`
- Modify: `mantle-network-primer/agents/openai.yaml`

**Step 1: Write the failing structural checks**

Run:

```bash
rg -n "^## Developer Hints|^## Mantle-Specific Differences|differences|operations|developer onboarding" mantle-network-primer/SKILL.md mantle-network-primer/references/mantle-network-basics.md mantle-network-primer/agents/openai.yaml
```

Expected:

- one or more required sections or phrases are absent

**Step 2: Write the minimal implementation**

Update the files so they:

- describe the skill as Mantle basics plus Mantle-specific developer onboarding
- switch the workflow classification from `comparison` to `differences`
- teach stable Mantle differences without naming other chains
- add a `Mantle-Specific Differences` section to the reference
- add a `Developer Hints` section to the reference
- keep volatile fee, throughput, and ecosystem claims explicitly out of the stable reference
- align the agent metadata with the expanded onboarding purpose

**Step 3: Run checks to verify the new structure**

Run:

```bash
rg -n "^## Developer Hints|^## Mantle-Specific Differences|differences|developer onboarding|rate-limited|MNT" mantle-network-primer/SKILL.md mantle-network-primer/references/mantle-network-basics.md mantle-network-primer/agents/openai.yaml
```

Expected:

- all required themes are now present

### Task 3: Verify retrieval outcomes

**Files:**
- Modify: `docs/skill-tests/2026-03-08-mantle-network-primer.md`

**Step 1: Write GREEN retrieval scenarios**

Record these prompts in the skill-test note:

- "What is Mantle and what makes it different for developers?"
- "Why do I need MNT if Mantle is EVM-compatible?"
- "Can I use the public Mantle RPC in production?"

**Step 2: Run lightweight verification checks**

Run:

```bash
rg -n "MNT|gas token|rate-limited|dedicated provider|inclusion|settlement|finality" mantle-network-primer/SKILL.md mantle-network-primer/references/mantle-network-basics.md
```

Expected:

- the skill and reference contain enough information to answer each prompt without relying on volatile claims

**Step 3: Record the GREEN result**

Append the verification output and a short success summary to `docs/skill-tests/2026-03-08-mantle-network-primer.md` under `## GREEN Verification`.
