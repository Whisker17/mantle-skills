# SkillsBench Remediation First Pass Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Tighten skill retrieval text, narrow the broadest skill boundaries, and reduce answer-heavy guidance in the highest-priority Mantle skills from the SkillsBench review.

**Architecture:** Keep this pass documentation-only and focused. Rewrite frontmatter descriptions so retrieval is trigger-first, refactor `mantle-defi-operator` into a clearer orchestrator over specialized skills, trim `mantle-network-primer` so it teaches stable concepts instead of canned answers, and apply one cheap registry data-quality fix that was called out in the review.

**Tech Stack:** Markdown skill documents, YAML agent metadata, JSON registry data, shell-based retrieval checks

---

### Task 1: Capture the failing baseline

**Files:**
- Create: `docs/skill-tests/2026-03-08-skillsbench-remediation.md`
- Inspect: `skills/*/SKILL.md`
- Inspect: `skills/mantle-defi-operator/references/defi-execution-guardrails.md`
- Inspect: `skills/mantle-defi-operator/references/protocol-selection-policy.md`
- Inspect: `skills/mantle-network-primer/references/mantle-network-basics.md`
- Inspect: `skills/mantle-address-registry-navigator/assets/registry.json`

**Step 1: Write the failing acceptance checks**

The first-pass remediation must satisfy all of the following:

- Every `SKILL.md` description starts with `Use when` and describes triggers instead of workflow.
- `mantle-defi-operator` reads as an orchestrator over address, risk, and allowance evidence rather than a monolith.
- `mantle-defi-operator/SKILL.md` no longer hardcodes curated protocol names inline.
- `mantle-network-primer` no longer relies on canned quick-answer templates.
- `mantle-network-primer` more clearly separates stable concepts from dated snapshot values.
- The local address registry has concrete Mantle chain IDs instead of `null`.

**Step 2: Run baseline checks to verify the gaps**

Run:

```bash
for f in skills/*/SKILL.md; do
  name=$(basename "$(dirname "$f")")
  desc=$(awk '/^description:/{sub(/^description:[ ]*/,""); print; exit}' "$f")
  case "$desc" in
    Use\ when*) ok=yes ;;
    *) ok=no ;;
  esac
  printf '%s\t%s\t%s\n' "$name" "$ok" "$desc"
done | sort

rg -n 'Merchant Moe|Agni|Aave v3|allowance|risk-evaluator|portfolio-analyst|DefiLlama|curated defaults' \
  skills/mantle-defi-operator/SKILL.md \
  skills/mantle-defi-operator/references/*.md

rg -n '^## Quick Templates|snapshot|latest|volatile|MNT|settlement|finality|rate-limited' \
  skills/mantle-network-primer/SKILL.md \
  skills/mantle-network-primer/references/mantle-network-basics.md

rg -n 'chain_ids|null' skills/mantle-address-registry-navigator/assets/registry.json
```

Expected:

- Multiple descriptions fail the `Use when` check.
- `mantle-defi-operator/SKILL.md` contains inline curated protocol names and mixes orchestration with allowance/risk logic.
- `mantle-network-primer/SKILL.md` still contains `## Quick Templates`.
- The registry file still shows `null` chain IDs.

### Task 2: Rewrite trigger descriptions repo-wide

**Files:**
- Modify: `skills/mantle-address-registry-navigator/SKILL.md`
- Modify: `skills/mantle-data-indexer/SKILL.md`
- Modify: `skills/mantle-defi-operator/SKILL.md`
- Modify: `skills/mantle-network-primer/SKILL.md`
- Modify: `skills/mantle-portfolio-analyst/SKILL.md`
- Modify: `skills/mantle-readonly-debugger/SKILL.md`
- Modify: `skills/mantle-risk-evaluator/SKILL.md`
- Modify: `skills/mantle-smart-contract-deployer/SKILL.md`
- Modify: `skills/mantle-smart-contract-developer/SKILL.md`
- Modify: `skills/mantle-tx-simulator/SKILL.md`

**Step 1: Write the failing structural check**

Run:

```bash
for f in skills/*/SKILL.md; do
  desc=$(awk '/^description:/{sub(/^description:[ ]*/,""); print; exit}' "$f")
  case "$desc" in
    Use\ when*) ;;
    *) exit 1 ;;
  esac
done
```

Expected:

- The command fails before the edits because several skills do not start with `Use when`.

**Step 2: Write the minimal implementation**

Update each skill description so it:

- starts with `Use when`
- describes triggering situations and symptoms
- avoids summarizing workflow or tool choreography

**Step 3: Re-run the description check**

Expected:

- The command succeeds with exit code `0`.

### Task 3: Narrow `mantle-defi-operator`

**Files:**
- Modify: `skills/mantle-defi-operator/SKILL.md`
- Modify: `skills/mantle-defi-operator/agents/openai.yaml`
- Modify: `skills/mantle-defi-operator/references/defi-execution-guardrails.md`
- Modify: `skills/mantle-defi-operator/references/protocol-selection-policy.md`

**Step 1: Write the failing boundary checks**

Run:

```bash
rg -n 'Merchant Moe|Agni|Aave v3|allowance prerequisites|Check allowance' skills/mantle-defi-operator/SKILL.md
```

Expected:

- The current skill inlines venue defaults and duplicates allowance/risk responsibilities.

**Step 2: Write the minimal implementation**

Refactor the skill so it:

- describes itself as a coordinator for verified venue selection and execution handoff
- routes address trust to `mantle-address-registry-navigator`
- routes risk verdicts to `$mantle-risk-evaluator`
- routes allowance and balance evidence to `$mantle-portfolio-analyst` when needed
- keeps curated defaults in references instead of hardcoding protocol names in the main skill

Update the guardrail/policy references so they reinforce orchestration boundaries rather than duplicating full logic.

**Step 3: Re-run the boundary checks**

Run:

```bash
rg -n 'mantle-address-registry-navigator|mantle-risk-evaluator|mantle-portfolio-analyst|supporting_skills_used|preflight_verdict' \
  skills/mantle-defi-operator/SKILL.md \
  skills/mantle-defi-operator/references/defi-execution-guardrails.md \
  skills/mantle-defi-operator/references/protocol-selection-policy.md
```

Expected:

- The skill and references show explicit orchestration boundaries and supporting-skill usage.

### Task 4: Trim `mantle-network-primer` and fix the registry snapshot

**Files:**
- Modify: `skills/mantle-network-primer/SKILL.md`
- Modify: `skills/mantle-network-primer/agents/openai.yaml`
- Modify: `skills/mantle-network-primer/references/mantle-network-basics.md`
- Modify: `skills/mantle-address-registry-navigator/assets/registry.json`

**Step 1: Write the failing checks**

Run:

```bash
rg -n '^## Quick Templates' skills/mantle-network-primer/SKILL.md
rg -n 'stable concepts|dated snapshot|live-verify' skills/mantle-network-primer/references/mantle-network-basics.md
rg -n 'chain_ids|null' skills/mantle-address-registry-navigator/assets/registry.json
```

Expected:

- The primer still contains quick templates.
- The reference does not yet have a dedicated stable-vs-snapshot usage note.
- The registry still contains `null` chain IDs.

**Step 2: Write the minimal implementation**

Update the primer so it:

- uses trigger-first description text
- removes canned quick templates
- explains how to answer with stable concepts first and dated snapshot values second

Update the primer reference so it clearly labels stable concepts versus dated snapshot values.

Update the registry chain IDs to concrete Mantle mainnet/testnet values.

**Step 3: Re-run the checks**

Expected:

- `## Quick Templates` is gone.
- The reference includes stable-vs-snapshot guidance.
- The registry chain IDs are populated.

### Task 5: Verify the first pass

**Files:**
- Verify: `docs/skill-tests/2026-03-08-skillsbench-remediation.md`
- Verify: `skills/*/SKILL.md`
- Verify: `skills/mantle-defi-operator/agents/openai.yaml`
- Verify: `skills/mantle-defi-operator/references/defi-execution-guardrails.md`
- Verify: `skills/mantle-defi-operator/references/protocol-selection-policy.md`
- Verify: `skills/mantle-network-primer/agents/openai.yaml`
- Verify: `skills/mantle-network-primer/references/mantle-network-basics.md`
- Verify: `skills/mantle-address-registry-navigator/assets/registry.json`

**Step 1: Run final verification**

Run:

```bash
for f in skills/*/SKILL.md; do
  desc=$(awk '/^description:/{sub(/^description:[ ]*/,""); print; exit}' "$f")
  case "$desc" in
    Use\ when*) ;;
    *) echo "bad description: $f"; exit 1 ;;
  esac
done

rg -n '^## Quick Templates' skills/mantle-network-primer/SKILL.md && exit 1 || true
rg -n 'Merchant Moe|Agni|Aave v3' skills/mantle-defi-operator/SKILL.md && exit 1 || true
rg -n 'stable concepts|dated snapshot|live-verify' skills/mantle-network-primer/references/mantle-network-basics.md
rg -n '"mainnet": 5000|"testnet": 5003' skills/mantle-address-registry-navigator/assets/registry.json
```

Expected:

- All descriptions are trigger-first.
- The primer no longer includes canned quick templates.
- The DeFi operator no longer inlines protocol defaults in the main skill.
- The reference and registry checks succeed.
