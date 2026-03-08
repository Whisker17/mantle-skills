# SkillsBench Remediation First Pass Skill Test

## Scope

This test note covers the first remediation slice from the SkillsBench-aligned review:

- trigger-first description cleanup across all skills
- boundary tightening for `mantle-defi-operator`
- answer-shape cleanup for `mantle-network-primer`
- local registry chain ID population

## RED Baseline

### Description retrieval check

Command:

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
```

Observed:

- `mantle-data-indexer`, `mantle-network-primer`, `mantle-portfolio-analyst`, `mantle-readonly-debugger`, and `mantle-risk-evaluator` failed the `Use when` shape check.

### `mantle-defi-operator` boundary check

Command:

```bash
rg -n 'Merchant Moe|Agni|Aave v3|allowance|risk-evaluator|portfolio-analyst|DefiLlama|curated defaults' \
  skills/mantle-defi-operator/SKILL.md \
  skills/mantle-defi-operator/references/*.md
```

Observed:

- `skills/mantle-defi-operator/SKILL.md` hardcoded curated venues inline.
- The main skill mixed orchestration with allowance handling and execution-readiness checks.
- The references already pointed to `$mantle-risk-evaluator`, but the main skill did not clearly frame itself as a coordinator over specialized skills.

### `mantle-network-primer` shape check

Command:

```bash
rg -n '^## Quick Templates|snapshot|latest|volatile|MNT|settlement|finality|rate-limited' \
  skills/mantle-network-primer/SKILL.md \
  skills/mantle-network-primer/references/mantle-network-basics.md
```

Observed:

- `skills/mantle-network-primer/SKILL.md` still exposed `## Quick Templates`.
- The reference already held good stable concepts, but the skill itself still encouraged template-like answers instead of a stable-concepts-first response shape.

### Address registry data-quality check

Command:

```bash
rg -n 'chain_ids|null' skills/mantle-address-registry-navigator/assets/registry.json
```

Observed:

- `skills/mantle-address-registry-navigator/assets/registry.json` still had `null` values for both chain IDs.

## GREEN Verification

### Description retrieval check

Command:

```bash
bad=0
for f in skills/*/SKILL.md; do
  desc=$(awk '/^description:/{sub(/^description:[ ]*/,""); print; exit}' "$f")
  case "$desc" in
    Use\ when*) ;;
    *) echo "bad description: $f"; bad=1 ;;
  esac
done
echo "$bad"
```

Observed:

- All 10 skills now start with `Use when`.
- The verification run reported `description_bad=0`.

### `mantle-defi-operator` boundary check

Command:

```bash
rg -n 'Merchant Moe|Agni|Aave v3' skills/mantle-defi-operator/SKILL.md
rg -n 'mantle-address-registry-navigator|mantle-risk-evaluator|mantle-portfolio-analyst|supporting_skills_used|preflight_verdict' \
  skills/mantle-defi-operator/SKILL.md \
  skills/mantle-defi-operator/references/defi-execution-guardrails.md \
  skills/mantle-defi-operator/references/protocol-selection-policy.md
```

Observed:

- The inline curated protocol names no longer appear in `skills/mantle-defi-operator/SKILL.md`.
- The skill and references now explicitly frame address trust, risk verdicts, and allowance evidence as supporting-skill inputs.
- The output schema now exposes `supporting_skills_used` and `preflight_verdict`.

### `mantle-network-primer` shape check

Command:

```bash
rg -n '^## Quick Templates' skills/mantle-network-primer/SKILL.md
rg -n 'stable-concepts layer|dated snapshots|live-verify|latest/current|Label snapshot values' \
  skills/mantle-network-primer/SKILL.md \
  skills/mantle-network-primer/references/mantle-network-basics.md
```

Observed:

- `## Quick Templates` is gone from `skills/mantle-network-primer/SKILL.md`.
- The skill now tells the agent to answer with stable concepts first and labeled snapshot details second.
- The reference now includes an explicit stable-vs-snapshot usage note.

### Address registry data-quality check

Command:

```bash
rg -n '"mainnet": 5000|"testnet": 5003|chain_ids' skills/mantle-address-registry-navigator/assets/registry.json
```

Observed:

- The local registry now includes Mantle mainnet/testnet chain IDs (`5000` and `5003`).
