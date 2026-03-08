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

## Required registry keys
- MERCHANT_MOE_ROUTER
- MERCHANT_MOE_LB_ROUTER
- MERCHANT_MOE_LB_QUOTER
- AGNI_ROUTER
- AGNI_POSITION_MANAGER
- AGNI_QUOTER
- AAVE_V3_POOL
- AAVE_V3_POOL_ADDRESSES_PROVIDER

## RED Baseline
### Skill text check
exit_code: 1
(no matches)

### Registry check
exit_code: 4

### AAVE_V3_POOL pre-check
exit_code: 4

### curated-defaults.yaml exists
exit_code: 1

### protocol-selection-policy.md exists
exit_code: 1

## GREEN Verification
### Scenario 1
Prompt:
"Use $mantle-defi-operator to plan a USDT -> WMNT swap on Mantle. Recommend the best protocol and provide the router address."

Result:
- Pass
- Recommended `Merchant Moe` first and cited the verified registry-backed router `MERCHANT_MOE_LB_ROUTER`
- Explained venue choice with liquidity / volume reasoning and listed `Agni` as `also_viable`

### Scenario 2
Prompt:
"Use $mantle-defi-operator to plan a WMNT supply flow on Mantle and suggest a lending venue."

Result:
- Pass after one wording refactor
- Recommends `Aave v3` first via `AAVE_V3_POOL`
- States that live TVL / utilization were not fetched and that curated-default fallback was used
- Separates recommendation from execution by keeping readiness at `needs_input`

### Scenario 3
Prompt:
"What other Mantle DeFi protocols should I look at besides your defaults?"

Result:
- Pass
- Returns curated defaults first (`Merchant Moe`, `Agni`, `Aave v3`)
- Mentions `DefiLlama` as discovery-only context
- Does not invent unverified addresses for additional protocols

### Loopholes Observed
- Initial Scenario 2 replay asked a follow-up preference question before making the first lending recommendation.
- Fixed by updating the skill and selection policy so a single curated, verified candidate is recommended before optimization follow-ups.
