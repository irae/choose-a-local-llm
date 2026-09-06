# Run 7 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. Three Gemma-4-12B (LM Studio) runs from this run are
excluded from the Mendel table below: they ran the retired thinking-
stuck-on entry and are marked invalid on the site; an invalid row is
never an old row or a new row. They are covered in the items below
instead.

Speed and context:

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | 11 | Gemma-4-12B, GGUF, MTP q8, thinking off | 11k | speed | 14.0 → 8 | 8.2 GB | 0.909/0.872/100% |
| new | — | Gemma-4-12B, GGUF, MTP q8, thinking off | **16k** | speed | **13.8 → 6.5** | **10.5 GB** | 0.909/0.872/100% |

Mendel:

| old/new | test | model | serving | score | worst defect |
|---|---|---|---|--:|---|
| old | blind | qwen3.6-35b-a3b, thinking on (prompt v1.0) | llama-server | 41.5/100 8/8 | critical |
| new | blind | qwen3.6-35b-a3b, high (prompt v1.1) | llama-server | **63/100** 8/8 | critical |
| new | blind | Qwen3.8-27B (mlx, low) | mlx_lm.server | 12.5/100 (partial 1/8) | minor (harness stall) |
| old | blind | Ternary-Bonsai-27B-mlx-2bit, thinking on (prompt v1.0) | mlx_lm.server | 37.5/100 (partial 3/8) | — |
| new | blind | Ternary-Bonsai-27B-mlx-2bit, low | mlx_lm.server | 37.5/100 (partial 3/8) | — |
| new | blind | bonsai-prism, high | llama-server | **60.5/100** 1/8 | critical (self-scoped to one library) |
| old | guided | qwen3.6-35b-a3b (prompt v2.1) | pi | 65.5/100 8/8 | — |
| new | guided | qwen3.6-35b-a3b, high (prompt v3.0) | pi | **83/100** 8/8 | critical |
| old | guided | Ternary-Bonsai-27B-mlx-2bit, thinking on (prompt v2.1) | pi | 37.5/100 (partial 3/8) | — |
| new | guided | Ternary-Bonsai-27B-mlx-2bit, low (prompt v3.0) | pi | **12.5/100** (partial 1/8) | — |
| old | guided | Qwen3.8-27B-4bit, low | pi | 75/100 (partial 6/8) | — |
| new | guided | Qwen3.8-27B-4bit, low (retry) | pi | **0/100** (partial 0/8) | tooling budget exhausted |

- **The Gemma-12B, LM Studio, thinking-stuck-on entry fails the same
  way three times.** Blind high (30.5), guided high (30), and guided
  low (29.5) all collapse into a newline flood after the first real
  edit attempt, regardless of the requested thinking level. Root
  cause: LM Studio cannot turn thinking off for this model (found in
  an earlier run's forensics), so every one of these runs is really
  testing the same broken thinking-on state. All three are marked
  invalid on the site; they are not old or new rows here.
- **Qwen3.8-27B-4bit's guided-low retry does worse, not better.** The
  earlier attempt (75, partial at 6 of 8 libraries) predates a naming
  collision fix in the run harness; this attempt hit the tooling-nudge
  budget (10 of 10) before finishing, with zero libraries done. The
  model does honor a low reasoning-effort request; the harness-side
  window mismatch is the open problem, not the model.
- **Bonsai-PrismML blind high needs a from-scratch retry.** The model
  typoed the repo path, got repeated 404s on the issue fetch, then
  self-scoped the whole task to one library found via `git log`. Its
  own task list was never wrong from the harness's point of view (it
  was fully checked), so no nudge fired. The owner's rule for the
  retry: a re-run after a model failure costs 10 points for each
  earlier valid attempt; this is now recorded in the Mendel plan.
- **Bonsai-PrismML guided high was aborted, not scored.** The owner
  stopped it mid-run for time, not because the model failed. Its
  worktree and branch were discarded on purpose; no row exists for it
  and none should be inferred from this run.
- **The Qwen3.6 and Bonsai MLX dagger sweeps did not run.** Both hit a
  GPU out-of-memory error when the run tried to start a large MTP
  server shortly after stopping a different large server. Later
  analysis of the memory-watcher log found free memory pinned near
  zero for the whole failed attempt — most likely too little recovery
  time after the prior server's shutdown, not a hard hardware ceiling.
  Deferred to a later run with an added rule: wait for free memory to
  return to its idle baseline before starting a large server, not just
  confirm the old process is gone.
- **Mendel score cells now carry the libraries done.** A partial score
  is capped at 12.5 points per completed library, so several cells
  above changed from the raw rubric total to the capped number: the
  two Bonsai blind rows (raw 58 and 55, both capped to 37.5 at 3 of 8
  libraries), the Bonsai guided rows (raw 69 capped to 37.5 at 3/8, raw
  59 capped to 12.5 at 1/8), the Qwen3.8-mlx-low blind row (raw 67.5
  capped to 12.5 at 1/8), and both Qwen3.8-27B-4bit guided-low rows
  (raw 84 capped to 75 at 6/8, raw 34 capped to 0 at 0/8).
- **The Gemma-12B GGUF dagger sweep re-confirmed, with a smaller
  floor.** Re-measured under the current 24000 MB wired limit: floor
  now crosses at 16,410 tokens, not the earlier 11K reading. Close to
  the earlier numbers otherwise (13.8/6.5 tok/s against 14.0/8),
  10.5 GB RSS. No load-time crash at `-c 262144`, unlike the same
  MTP-drafter pattern on Qwen3.6-35B-A3B.
