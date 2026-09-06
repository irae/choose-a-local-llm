# Run 9 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules.

Quality:

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | 10 | Gemma-4-12B, MLX³, thinking off | 158k* | mem | 35.4 → 29.29 | 8.1 GB | 0.909/0.872/100% |
| new | — | Gemma-4-12B, GGUF, MTP q8, thinking off | 16k | speed | 13.8 → 6.5 | 10.5 GB | **0.976/0.939/100%** |

Speed and context:

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | 5 | Qwen3.6-35B-A3B, GGUF, MTP q8, thinking on | 90k | speed | 44 → 8.1 | 22.8 GB | 0.939/0.921 |
| new | — | Qwen3.6-35B-A3B, GGUF, MTP q8, thinking on | **8k** | **mem** | **36.4 → 43.8** | **25.0 GB** | 0.939/0.921 |
| old | 3 | Qwen3.8-27B, GGUF, MTP q8, effort medium | 19k | speed | 14.1 → 8 | 18.9 GB | 0.982/0.939 |
| new | — | Qwen3.8-27B, GGUF, MTP f16, effort medium | **49k** | **mem** | **20.0 → 15.0** | **23.5 GB** | 0.982/0.939 |
| old | 7 | Gemma-4-26B-A4B, GGUF, MTP q8 | 24k | speed | 23.5 → 8 | 15.4 GB | 0.713/0.701 (MLX copy) |
| new | — | Gemma-4-26B-A4B, GGUF, MTP f16 | **197k** | **mem** | **60.3 → 17.3** | **25.6 GB** | 0.713/0.701 (MLX copy) |

Mendel:

| old/new | test | model | serving | score | worst defect |
|---|---|---|---|--:|---|
| old | guided | Ternary-Bonsai-27B-mlx-2bit, low (nearest scored local row, prompt v3.0) | mlx_lm.server | 59/100 (partial) | — |
| new | guided | Gemma-4-12B, GGUF, f16 KV, no MTP, thinking off | pi | **37.5/100 (partial)** | — |
| new | guided | Qwen3.8-27B (mlx, low) | mlx_lm.server | — | — |

Gates:

| old/new | gate | model | config | result | verdict |
|---|---|---|---|---|---|
| new | evalplus smoke | qwen3.8-27b | GGUF f16 vs q8_0, effort medium | both arms 4/4 passed, 0 empty | level |
| new | evalplus smoke | gemma-4-26b-a4b | GGUF f16 vs q8_0, thinking on | both arms 3/4 passed, 1 empty (HumanEval/129, thinking non-convergence) | level |

- **Gemma-12B GGUF quality.** The GGUF Q4_K_XL quant did not share a
  score with the LM Studio MLX 4-bit build before this run. This run
  scored it for the first time, at f16 KV, thinking off, 0 empty. It
  beats the MLX score by 0.067 on both base and plus. The published
  row keeps its own speed and memory numbers (measured earlier, on the
  q8_0 MTP arm); only the quality cell changed, because KV cache type
  does not change output quality on this model.
- **KV cache type set the real ceiling on all three GGUF models.** Qwen3.8
  and Gemma-26B move from q8_0 to f16: f16 wins by more than 2x at
  depth, at the same or lower memory. Qwen3.6 stays on q8_0: its f16
  arm cannot even load at `-c 40960` under the 24000 MB wired limit.
- **Every published `-c` OOMs at load.** The run found the true hardware
  ceiling for each f16 pick by binary search, not by trusting the
  published `-c`: Qwen3.8 lands at `-c 49152` (not 32768), Gemma-26B at
  `-c 212992` (not 262144). A first pass on both models stopped at an
  undersized `-c` and read it as a window; that reading was wrong and
  is corrected in the numbers above. The fix and the reasoning are in
  `docs/methodology/checklist.md`.
- **Qwen3.6's deep-context claim does not survive a real creep.** The
  published `-c 98304` OOMs at load; the largest that loads is
  `-c 49152`. At that `-c`, memory compaction starts by depth 16386 and
  the last clean row is depth 8222 at 43.8 tok/s — far shallower than
  the 90k the site carried before this run.
- **Both f16 smokes read level with their q8_0 counterpart.** Same pass
  count and same empty count on both KV types, so the KV pick changes
  speed and memory only, never quality. The Gemma-26B smoke reproduces
  the model's known thinking non-convergence identically on both
  types (1 of 4 problems hits the token budget without finishing).
- **Gemma-12B guided-off is a first scored row, not a replacement.** No
  earlier valid guided row exists for this model: the three prior
  Gemma-12B guided attempts on the retired LM Studio entry are invalid
  (thinking stuck on, pre-fix chat template, a repetition loop, zero
  commits) and an invalid row is never an old row. The nearest scored
  local guided row at the time, shown above for reference only, is
  Bonsai on the prism fork at low reasoning effort. Gemma-12B stopped
  at 3 of 8 libraries on `model_budget_exhausted`, the same signature
  as the retired LM Studio entry's high-effort attempt.
- **Qwen3.8 MLX guided-low stays invalid after three attempts, root
  cause found.** The `maxTokens` fix from the previous run works: no
  crash comes from a budget/window mismatch at request time. But the
  model still grows its context past the configured 26624-token window
  during real agentic use, and Metal crashes the generation thread
  twice while the server keeps answering `/health` with 200. Zero
  commits on both real attempts. This is now a separate open problem:
  a smaller context window, an earlier compaction trigger, or dropping
  the prompt cache size, needs its own investigation before a fourth
  attempt.
- **Bonsai MLX guided and blind, thinking off, did not run.** The owner
  deferred block C to run 10.
