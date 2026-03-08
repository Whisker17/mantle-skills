# Mantle DeFi Operator Boundary and Evidence Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Tighten `mantle-defi-operator` so it behaves as a coordinator with explicit mode boundaries and evidence references instead of an all-in-one DeFi expert.

**Architecture:** Keep the change documentation-only. Add a `When Not to Use` section, make discovery/compare/execution modes stricter, extend the report schema with upstream evidence references, and enrich curated defaults with freshness and rationale metadata.

**Tech Stack:** Markdown skill documents, YAML agent metadata, YAML reference data, shell-based retrieval checks

---

### Task 1: Capture the failing baseline

**Files:**
- Create: `docs/skill-tests/2026-03-08-mantle-defi-operator-boundary-evidence.md`
- Inspect: `skills/mantle-defi-operator/SKILL.md`
- Inspect: `skills/mantle-defi-operator/references/curated-defaults.yaml`
- Inspect: `skills/mantle-defi-operator/references/protocol-selection-policy.md`

**Step 1: Write the failing checks**

The tightened operator must satisfy all of the following:

- It includes a `When Not to Use` section.
- It exposes `planning_mode` and upstream evidence-reference fields.
- It forbids router/call-data style execution details in `discovery_only`.
- Curated defaults include freshness and rationale metadata.

**Step 2: Run baseline checks**

Run:

```bash
rg -n '^## When Not to Use|planning_mode|address_resolution_ref|risk_report_ref|portfolio_report_ref|discovery_only.*router|compare_only.*calldata' \
  skills/mantle-defi-operator/SKILL.md \
  skills/mantle-defi-operator/references/protocol-selection-policy.md \
  skills/mantle-defi-operator/references/curated-defaults.yaml

rg -n 'source_url|retrieved_at|review_after|why_default|protocol_id:' \
  skills/mantle-defi-operator/references/curated-defaults.yaml
```

Expected:

- The checks produce no matches before the patch.

### Task 2: Patch the operator boundary

**Files:**
- Modify: `skills/mantle-defi-operator/SKILL.md`
- Modify: `skills/mantle-defi-operator/agents/openai.yaml`
- Modify: `skills/mantle-defi-operator/references/protocol-selection-policy.md`
- Modify: `skills/mantle-defi-operator/references/curated-defaults.yaml`

**Step 1: Add boundary guidance**

Update the skill so it:

- adds `## When Not to Use`
- treats `discovery_only` and `compare_only` as hard output boundaries
- requires evidence handles for address, risk, and portfolio inputs

**Step 2: Add curated metadata**

Update `curated-defaults.yaml` so each default includes:

- `protocol_id`
- `source_url`
- `retrieved_at`
- `review_after`
- `why_default`

**Step 3: Re-run checks**

Expected:

- The new sections and fields are retrievable.
- Curated defaults carry freshness metadata.
