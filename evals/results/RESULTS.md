# mantle-skills Eval Results

## Full Suite Runs: 2026-03-11 to 2026-03-12

71 evals across 10 skills. Two model configurations were tested with and without Mantle skills loaded.

### Setup

- **Models tested:** `openrouter/arcee-ai/trinity-large-preview:free`, `openai/gpt-5.2`
- **Judge model:** same as tested model in each run
- **Evals:** 71 total across 10 skill suites
- **A/B test:** each prompt run twice (`with skill` vs `bare`)
- **Result folders:**
  - `evals/results/batches/openrouter-all-skills-2026-03-11T16-35-54Z`
  - `evals/results/batches/openai-all-skills-2026-03-12T02-12-17Z`

---

## Summary


|                        | OpenRouter Trinity                      | OpenAI GPT-5.2                         |
| ---------------------- | --------------------------------------- | -------------------------------------- |
| Skills completed       | 9 / 10                                  | 3 / 10                                 |
| Evals completed        | 65 / 71                                 | 18 / 71                                |
| **With skill**         | **96.9%** (63 pass, 1 partial, 1 fail)  | **88.9%** (16 pass, 1 partial, 1 fail) |
| **Without skill**      | **21.5%** (14 pass, 7 partial, 44 fail) | **5.6%** (1 pass, 3 partial, 14 fail)  |
| **Uplift (pass rate)** | **+75.4 pts**                           | **+83.3 pts**                          |
| Comparison counts      | 50 skill_better, 15 same, 0 bare_better | 15 skill_better, 3 same, 0 bare_better |


---

## Results By Skill

Legend: `✅ pass`, `⚠️ partial`, `❌ fail`, `— not completed`


| Skill                    | Evals | OpenRouter w/    | OpenRouter w/o   | OpenAI w/        | OpenAI w/o       |
| ------------------------ | ----- | ---------------- | ---------------- | ---------------- | ---------------- |
| address-registry         | 8     | ✅ 8 / ⚠️ 0 / ❌ 0 | ✅ 1 / ⚠️ 0 / ❌ 7 | —                | —                |
| data-indexer             | 6     | —                | —                | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 1 / ⚠️ 1 / ❌ 4 |
| defi-operator            | 10    | ✅ 9 / ⚠️ 1 / ❌ 0 | ✅ 3 / ⚠️ 0 / ❌ 7 | —                | —                |
| network-primer           | 9     | ✅ 9 / ⚠️ 0 / ❌ 0 | ✅ 2 / ⚠️ 0 / ❌ 7 | —                | —                |
| portfolio-analyst        | 6     | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 0 / ⚠️ 0 / ❌ 6 | ✅ 5 / ⚠️ 0 / ❌ 1 | ✅ 0 / ⚠️ 0 / ❌ 6 |
| readonly-debugger        | 6     | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 3 / ⚠️ 2 / ❌ 1 | —                | —                |
| risk-evaluator           | 8     | ✅ 7 / ⚠️ 0 / ❌ 1 | ✅ 1 / ⚠️ 1 / ❌ 6 | —                | —                |
| smart-contract-deployer  | 6     | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 1 / ⚠️ 1 / ❌ 4 | ✅ 5 / ⚠️ 1 / ❌ 0 | ✅ 0 / ⚠️ 2 / ❌ 4 |
| smart-contract-developer | 6     | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 1 / ⚠️ 2 / ❌ 3 | —                | —                |
| tx-simulator             | 6     | ✅ 6 / ⚠️ 0 / ❌ 0 | ✅ 2 / ⚠️ 1 / ❌ 3 | —                | —                |


---

## Key Findings

1. Skill loading materially improves accuracy for both tested model configurations, with no case where bare outperformed skill-loaded responses in completed suites.
2. OpenRouter run completed 9 of 10 skill suites and reached high with-skill pass rates across most completed suites.
3. OpenAI run completed 3 of 10 skill suites; completed suites still show large uplift versus bare baselines.
4. On completed data, both models are much weaker in bare mode than in skill-loaded mode, which validates the eval suite's intended signal.

---

## Notes

- The OpenRouter batch has one suite marked incomplete (`data-indexer`).
- The OpenAI batch has seven suites marked incomplete.
- Completion counts are taken from `summary.json` and per-skill result file presence in each batch directory.
