# Mantle Smart Contract Skill Split Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Split Mantle smart contract support into a Mantle-specific contract development skill and a deployment/verification skill with a clear OpenZeppelin MCP handoff for contract authoring.

**Architecture:** Keep `mantle-smart-contract-deployer` narrowly scoped to deployment preparation, external execution handoff, and explorer verification. Add a new `mantle-smart-contract-developer` skill that owns Mantle-specific contract design and readiness guidance while explicitly routing contract-writing assistance through OpenZeppelin MCP.

**Tech Stack:** Markdown skill documents, YAML agent metadata, local reference markdown files

---

### Task 1: Capture the failing baseline

**Files:**
- Modify: `docs/plans/2026-03-08-mantle-smart-contract-skill-split.md`
- Inspect: `mantle-smart-contract-deployer/SKILL.md`
- Inspect: `mantle-smart-contract-deployer/agents/openai.yaml`

**Step 1: Write the failing acceptance checks**

The updated skill set must satisfy all of the following:

- A new `mantle-smart-contract-developer` skill exists.
- The new skill is Mantle-specific, not generic Solidity guidance.
- The new skill explicitly routes contract authoring to OpenZeppelin MCP.
- `mantle-smart-contract-deployer` remains focused on deployment and verification only.
- Both skills have distinct trigger descriptions and agent metadata.

**Step 2: Run the baseline checks to verify they fail**

Run:

```bash
test -f mantle-smart-contract-developer/SKILL.md
rg -n "OpenZeppelin|developer|development" mantle-smart-contract-deployer/SKILL.md
```

Expected:

- `test -f` fails because the new skill does not exist.
- `rg` shows the deployer skill does not clearly define the OpenZeppelin MCP boundary or the new split.

**Step 3: Document the baseline finding**

Record that the repository currently has one deployment-focused skill only, so the requested lifecycle split is missing.

### Task 2: Create the Mantle contract developer skill

**Files:**
- Create: `mantle-smart-contract-developer/SKILL.md`
- Create: `mantle-smart-contract-developer/agents/openai.yaml`
- Create: `mantle-smart-contract-developer/references/development-checklist.md`
- Create: `mantle-smart-contract-developer/references/openzeppelin-mcp-handoff.md`

**Step 1: Write the failing structural checks**

Run:

```bash
test -f mantle-smart-contract-developer/SKILL.md
test -f mantle-smart-contract-developer/agents/openai.yaml
test -f mantle-smart-contract-developer/references/development-checklist.md
test -f mantle-smart-contract-developer/references/openzeppelin-mcp-handoff.md
```

Expected:

- All commands fail because the new skill files do not exist yet.

**Step 2: Write the minimal implementation**

Create a new skill that:

- uses a trigger description focused on Mantle contract development work
- states that OpenZeppelin MCP is the required path for contract-writing assistance
- adds a Mantle-specific workflow for requirements, architecture, contract patterns, access control, upgradeability choices, dependencies, and deployment readiness
- ends with a handoff into `mantle-smart-contract-deployer`

Create references that:

- provide a Mantle contract development checklist
- explain when and how to hand off contract authoring questions to OpenZeppelin MCP

Create agent metadata with a distinct display name, short description, and default prompt.

**Step 3: Run checks to verify the files now exist**

Run:

```bash
test -f mantle-smart-contract-developer/SKILL.md
test -f mantle-smart-contract-developer/agents/openai.yaml
test -f mantle-smart-contract-developer/references/development-checklist.md
test -f mantle-smart-contract-developer/references/openzeppelin-mcp-handoff.md
```

Expected:

- All commands succeed with exit code `0`.

### Task 3: Narrow the deployer skill boundary

**Files:**
- Modify: `mantle-smart-contract-deployer/SKILL.md`
- Modify: `mantle-smart-contract-deployer/agents/openai.yaml`

**Step 1: Write the failing content checks**

Run:

```bash
rg -n "development|write|authoring|OpenZeppelin MCP" mantle-smart-contract-deployer/SKILL.md
```

Expected:

- The skill wording is not yet explicit enough about staying out of contract development and OpenZeppelin MCP guidance.

**Step 2: Write the minimal implementation**

Update the deployer skill so it:

- keeps its current deployment and verification workflow
- explicitly states it starts after contract design and implementation are already decided
- points contract development requests to `mantle-smart-contract-developer`
- keeps the read-only execution guardrails intact

Update the agent metadata so the prompt and short description reinforce deployment-only usage.

**Step 3: Run checks to verify the new boundary is present**

Run:

```bash
rg -n "mantle-smart-contract-developer|deployment|verification|external" mantle-smart-contract-deployer/SKILL.md
sed -n '1,40p' mantle-smart-contract-deployer/agents/openai.yaml
```

Expected:

- The deployer skill explicitly points development requests to the new skill.
- Agent metadata describes deployment/verification rather than full contract lifecycle work.

### Task 4: Verify structure and wording

**Files:**
- Verify: `mantle-smart-contract-developer/SKILL.md`
- Verify: `mantle-smart-contract-developer/agents/openai.yaml`
- Verify: `mantle-smart-contract-developer/references/development-checklist.md`
- Verify: `mantle-smart-contract-developer/references/openzeppelin-mcp-handoff.md`
- Verify: `mantle-smart-contract-deployer/SKILL.md`
- Verify: `mantle-smart-contract-deployer/agents/openai.yaml`

**Step 1: Run structural validation**

Run:

```bash
for f in \
  mantle-smart-contract-developer/SKILL.md \
  mantle-smart-contract-developer/agents/openai.yaml \
  mantle-smart-contract-developer/references/development-checklist.md \
  mantle-smart-contract-developer/references/openzeppelin-mcp-handoff.md \
  mantle-smart-contract-deployer/SKILL.md \
  mantle-smart-contract-deployer/agents/openai.yaml
do
  test -f "$f" || exit 1
done
```

Expected:

- Every required file exists.

**Step 2: Run wording validation**

Run:

```bash
rg -n "^description:" mantle-smart-contract-developer/SKILL.md mantle-smart-contract-deployer/SKILL.md
rg -n "OpenZeppelin MCP|mantle-smart-contract-deployer|mantle-smart-contract-developer" \
  mantle-smart-contract-developer/SKILL.md \
  mantle-smart-contract-developer/references/openzeppelin-mcp-handoff.md \
  mantle-smart-contract-deployer/SKILL.md
```

Expected:

- Both skills have trigger-oriented descriptions.
- The developer skill references OpenZeppelin MCP.
- The deployer skill references the new developer skill boundary.

**Step 3: Optional commit**

Run:

```bash
git add \
  docs/plans/2026-03-08-mantle-smart-contract-skill-split.md \
  mantle-smart-contract-developer \
  mantle-smart-contract-deployer/SKILL.md \
  mantle-smart-contract-deployer/agents/openai.yaml
git commit -m "feat: split mantle smart contract developer and deployer skills"
```

Expected:

- A focused commit is created if the user wants version control recorded in this session.
