# Run 5 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. This run scored no EvalPlus and had no gate decision,
so the Quality and Gates tables have no rows and are left out. The
Mendel mirror (`benchmarks/mendel/`) did not exist before this run —
every Mendel row below is a first appearance, with no old row to pair.

Speed and context:

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | 13 | Ternary-Bonsai-27B, GGUF, q4, thinking on | pending | speed | 14.6 → pending | 9.8 GB | 0.927/0.890 |
| new | — | Ternary-Bonsai-27B, GGUF, q4, thinking on | **33k** | speed | **14.8 → 7.9** | **9.6 GB** | 0.927/0.890 |
| old | 14 | Ternary-Bonsai-27B, GGUF, q4, 2 slots, thinking on | 2x48k | speed | 14.9 → 7.9 | 10.0 GB | 0.927/0.890 |
| new | — | Ternary-Bonsai-27B, GGUF, q4, 2 slots, thinking on | 2x48k | speed | 14.9 → **7.8** | **10.9 GB** | 0.927/0.890 |
| old | 8 | Gemma-4-12B, MLX³, thinking on | 158k* | mem | 37 → 29.29 | 8.8 GB | pending |
| new | — | Gemma-4-12B, MLX³, thinking on | 158k* | mem | **35.4** → 29.29 | **8.1 GB** | pending |
| old | 9 | Gemma-4-12B, MLX³, thinking off | 158k* | mem | 37 → 29.29 | 8.8 GB | 0.909/0.872 |
| new | — | Gemma-4-12B, MLX³, thinking off | 158k* | mem | **35.4** → 29.29 | **8.1 GB** | 0.909/0.872 |

Mendel:

| old/new | test | model | serving | score | worst defect |
|---|---|---|---|--:|---|
| new | blind | Ternary-Bonsai-27B-mlx-2bit | mlx_lm.server | 55/100 (partial) | — |
| new | blind | Qwen3.8-27B, effort medium | mlx_lm.server | 79.5/100 (partial) | — |
| new | guided | Qwen3.6-35B-A3B | pi | 67.5/100 | — |
| new | guided | Ternary-Bonsai-27B-mlx-2bit | pi | 70/100 (partial) | — |
| new | guided | Qwen3.8-27B, effort low | pi | 84/100 (partial) | — |

- **The guided Mendel track starts this run.** The owner added a
  structured, traps-disclosed prompt track alongside the existing
  terse blind prompt, and asked every local model with a blind score
  to get a guided run too, best to worst by EvalPlus plus score. This
  is the first data on either track that the site mirrors.
- **Bonsai's two dagger sweeps confirm the rotation and bias flags do
  not move the floor.** Single-slot and 2-slot both land at a 33K-token
  speed floor, matching the plain-q4 proxy measured earlier. Both
  rows' stale markers clear.
- **The Gemma-12B LM Studio shallow read was unverified before this
  run.** The re-measured 35.4 tok/s and 8.1 GB (both LM Studio rows
  share the curve) replace an earlier 37 tok/s / 8.8 GB reading and
  match the clean 65K/29.29 tok/s ceiling found earlier.
- **Qwen3.6-35B-A3B's MTP drafter fails to allocate on the current
  brew llama.cpp build**, and once it fails the whole backend answers
  every completion with HTTP 500 while `/health` stays ready — at two
  context sizes, GPU idle beforehand, so not a memory-pressure fluke.
  The guided run used the no-drafter command instead; Mendel does not
  measure tok/s, so scoring is unaffected. The site's own tok/s figures
  for this config are unverified against the current build and may
  need a re-check before the next depth sweep.
- **Gemma-12B thinking-on EvalPlus paused at 98/164** on the owner's
  instruction, to give the rest of the night to the new guided queue.
  It resumes in run 6.
- **Gemma-12B LM Studio guided and Qwen3.8-27B medium guided were
  queued but did not run this night** — the queue closed before
  reaching them.
