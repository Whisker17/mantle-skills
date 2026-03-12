# mantle-skills Eval Results

## Full Suite Runs: 2026-03-11 to 2026-03-12

71 evals across 10 skills. Two model configurations were tested with and without Mantle skills loaded.

### Setup

- **Models tested:** `openrouter/arcee-ai/trinity-large-preview:free`, `openai/gpt-5.2`
- **Model selection rationale:**
  - `openrouter/arcee-ai/trinity-large-preview:free` was chosen to test skill uplift when base model capability is relatively weak; model page: [OpenRouter - Trinity Large Preview (free)](https://openrouter.ai/arcee-ai/trinity-large-preview:free)
  - `openai/gpt-5.2` was used as a stronger reference model for comparison
- **Judge model:** same as tested model in each run
- **Evals:** 71 total across 10 skill suites
- **A/B test:** each prompt run twice (`with skill` vs `bare`)
- **Result folders:**
  - [`evals/results/batches/openrouter-all-skills-2026-03-12T04-15-28Z`](./batches/openrouter-all-skills-2026-03-12T04-15-28Z)
  - [`evals/results/batches/openai-all-skills-2026-03-12T02-12-17Z`](./batches/openai-all-skills-2026-03-12T02-12-17Z)

---

## Summary


|                        | OpenRouter Trinity                      | OpenAI GPT-5.2                         |
| ---------------------- | --------------------------------------- | -------------------------------------- |
| Skills completed       | 10 / 10                                 | 3 / 10                                 |
| Evals completed        | 71 / 71                                 | 18 / 71                                |
| **With skill**         | **97.2%** (69 pass, 0 partial, 2 fail)  | **88.9%** (16 pass, 1 partial, 1 fail) |
| **Without skill**      | **29.6%** (21 pass, 5 partial, 45 fail) | **5.6%** (1 pass, 3 partial, 14 fail)  |
| **Uplift (pass rate)** | **+67.6 pts**                           | **+83.3 pts**                          |
| Comparison counts      | 48 skill_better, 23 same, 0 bare_better | 15 skill_better, 3 same, 0 bare_better |


---

## Results By Skill

Legend: `✅ pass`, `⚠️ partial`, `❌ fail`, `— not completed`


| Skill                    | Evals | JSON | OpenRouter w/    | OpenRouter w/o   | OpenAI w/        | OpenAI w/o       |
| ------------------------ | ----- | ---- | ---------------- | ---------------- | ---------------- | ---------------- |
| address-registry         | 8     | [OpenRouter](./batches/openrouter-all-skills-2026-03-12T04-15-28Z/address-registry.json) | ✅ 8 / ⚠️ 0 / ❌ 0 | ✅ 3 / ⚠️ 0 / ❌ 5 | —                | —                |
| data-indexer             | 6     | [OpenRouter](./batches/openrouter-all-skills-2026-03-12T04-15-28Z/data-indexer.json), [OpenAI](./batches/openai-all-skills-2026-03-12T02-12-17Z/data-indexer.json) | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 2 / ⚠️ 0 / ❌ 4 | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 1 / ⚠️ 1 / ❌ 4 |
| defi-operator            | 10    | [OpenRouter](./batches/openrouter-all-skills-2026-03-12T04-15-28Z/defi-operator.json) | ✅ 10 / ⚠️ 0 / ❌ 0 | ✅ 3 / ⚠️ 1 / ❌ 6 | —                | —                |
| network-primer           | 9     | [OpenRouter](./batches/openrouter-all-skills-2026-03-12T04-15-28Z/network-primer.json) | ✅ 9 / ⚠️ 0 / ❌ 0 | ✅ 3 / ⚠️ 0 / ❌ 6 | —                | —                |
| portfolio-analyst        | 6     | [OpenRouter](./batches/openrouter-all-skills-2026-03-12T04-15-28Z/portfolio-analyst.json), [OpenAI](./batches/openai-all-skills-2026-03-12T02-12-17Z/portfolio-analyst.json) | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 0 / ⚠️ 0 / ❌ 6 | ✅ 5 / ⚠️ 0 / ❌ 1 | ✅ 0 / ⚠️ 0 / ❌ 6 |
| readonly-debugger        | 6     | [OpenRouter](./batches/openrouter-all-skills-2026-03-12T04-15-28Z/readonly-debugger.json) | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 3 / ⚠️ 1 / ❌ 2 | —                | —                |
| risk-evaluator           | 8     | [OpenRouter](./batches/openrouter-all-skills-2026-03-12T04-15-28Z/risk-evaluator.json) | ✅ 6 / ⚠️ 0 / ❌ 2 | ✅ 2 / ⚠️ 0 / ❌ 6 | —                | —                |
| smart-contract-deployer  | 6     | [OpenRouter](./batches/openrouter-all-skills-2026-03-12T04-15-28Z/smart-contract-deployer.json), [OpenAI](./batches/openai-all-skills-2026-03-12T02-12-17Z/smart-contract-deployer.json) | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 1 / ⚠️ 1 / ❌ 4 | ✅ 5 / ⚠️ 1 / ❌ 0 | ✅ 0 / ⚠️ 2 / ❌ 4 |
| smart-contract-developer | 6     | [OpenRouter](./batches/openrouter-all-skills-2026-03-12T04-15-28Z/smart-contract-developer.json) | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 1 / ⚠️ 2 / ❌ 3 | —                | —                |
| tx-simulator             | 6     | [OpenRouter](./batches/openrouter-all-skills-2026-03-12T04-15-28Z/tx-simulator.json) | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 3 / ⚠️ 0 / ❌ 3 | —                | —                |


---

## Key Findings

1. Skill loading materially improves accuracy for both tested model configurations, with no case where bare outperformed skill-loaded responses in completed suites.
2. OpenRouter run completed all 10 skill suites and covered the full 71-eval set.
3. OpenAI run completed 3 of 10 skill suites; completed suites still show large uplift versus bare baselines.
4. On completed data, both models are much weaker in bare mode than in skill-loaded mode, which validates the eval suite's intended signal.

---

## Notes

- The OpenAI batch has seven suites marked incomplete.
- Completion counts are taken from `summary.json` and per-skill result file presence in each batch directory.
