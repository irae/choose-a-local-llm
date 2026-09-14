# Run 10 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules.

Quality:

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | 16 | Gemma-4-26B-A4B, MLX, thinking on | 70k | mem | 51 → 12.8 | 20.0 GB | 0.713/0.701/72% |
| new | — | Gemma-4-26B-A4B, GGUF, MTP f16, thinking on | 197k | mem | 60.3 → 17.3 | 25.6 GB | **0.884/0.860/89%** |
| old | — | Gemma-4-26B-A4B, GGUF, MTP f16, thinking on (this run) | 197k | mem | 60.3 → 17.3 | 25.6 GB | 0.884/0.860/89% |
| new | — | Gemma-4-26B-A4B, GGUF, MTP f16, thinking off | 197k | mem | 60.3 → 17.3 | 25.6 GB | **0.976/0.945/100%** |
| old | 8 | Qwen3.6-35B-A3B, GGUF, MTP q8, thinking on | 8k | mem | 36.4 → 43.8 | 25.0 GB | 0.939/0.921/97% |
| new | — | Qwen3.6-35B-A3B, GGUF, MTP q8, thinking off | 8k | mem | 36.4 → 43.8 | 25.0 GB | **0.951/0.915/100%** |

Speed and context:

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | — | Gemma-4-12B, GGUF, MTP q8, 4 slots, thinking off | 4x256k | speed | 33.7 → pending | 16.9 GB | 0.976/0.939/100% |
| new | — | Gemma-4-12B, GGUF, MTP f16, 4 slots, thinking off | **4x49k** | **mem** | **42.9 → 27.7** | **25.1 GB** | 0.976/0.939/100% |
| old | — | Gemma-4-26B-A4B, GGUF, MTP q8, 2 slots | 2x184k | speed | pending → pending | pending | 0.713/0.701/72% (MLX copy) |
| new | — | Gemma-4-26B-A4B, GGUF, MTP f16, 2 slots | **2x82k** | **window** | **66.6 → 33.6** | **25.3 GB** | **0.884/0.860/89%** |
| old | 13 | Gemma-4-12B, MLX³, thinking off | 131k | mem | 34.19 → 23.23 | pending | 0.909/0.872/100% |
| new | — | Gemma-4-12B, MLX³, thinking off | 131k | mem | 34.19 → 23.23 | **17.2 GB** | 0.909/0.872/100% |

Mendel:

| old/new | test | model | serving | score | worst defect |
|---|---|---|---|--:|---|
| old | blind | Qwen3.8-27B (mlx, medium) | mlx_lm.server | 80/100 (partial 3/8) | medium |
| new | blind | qwen3.8-27b, GGUF f16 -c 49152, medium | llama-server | **87/100** 8/8 | minor |
| old | blind | gemma-4-26b-a4b, GGUF q8_0 (prompt v1.0) | llama-server | 38/100 (partial) | critical |
| new | blind | gemma-4-26b-a4b, GGUF f16 -c 212992, high | llama-server | **47.5/100** 8/8 | critical |

Gates:

| old/new | gate | model | config | result | verdict |
|---|---|---|---|---|---|
| new | mendel smoke | qwen3.8-27b | GGUF f16, medium | 8 calls, 1 commit, no loop, 62 s | pass |
| new | evalplus threshold | gemma-4-26b-a4b | GGUF f16, thinking on | base 0.884 against 0.800 | pass, on to Mendel |
| new | mendel smoke | gemma-4-26b-a4b | GGUF f16, high | 11 calls, 1 commit, no loop, 31 s | pass |
| new | mendel smoke | bonsai-27b | MLX, off | 14 calls, 1 commit, no loop, 115 s | pass |
| new | mendel smoke | gemma-4-26b-a4b | GGUF f16, off | 9 calls, 1 commit, no loop, 16 s | pass |

- **Gemma-26B, thinking on.** The old score was measured on the MLX
  build (2026-08-29) and carried to the GGUF rows by the shared-score
  rule; this run scored the GGUF quant itself. The two builds no longer
  share a score.
- **Gemma-26B, thinking off.** No earlier thinking-off run exists, so
  the pair is this run's own thinking-on score of the same build.
- **Qwen3.6, thinking off.** The pair is the thinking-on run of the
  same build (2026-08-29). Base up, plus down, the five empties gone.
- **Gemma-26B, 2-slot config.** Its EvalPlus cell also carried the MLX
  score, not the GGUF q8_0 speed row's own. This run's Block C score
  now covers both the 1-slot and the 2-slot GGUF f16 rows; neither
  carries the MLX copy any more.
- **Block A found real numbers where the site had `pending`.** All
  three configs (Gemma-12B 4-slot, Gemma-26B 2-slot, the LM Studio
  Gemma-12B row) had a published config with an unmeasured cell. The
  published `-c` values did not load on any of them; each was
  binary-searched down, verified with a real 4096-token completion (a
  trivial warmup was not enough — a false-positive OOM cost a step on
  both A1 and A2 before this check was added). Gemma-12B 4-slot moved
  from q8_0 to f16 and stopped on memory at depth 49198 (swap growth,
  against a baseline where swap was already in use at session start).
  Gemma-26B 2-slot moved from q8_0 to f16 and stopped on the search-bound
  `-c` itself (a **window** verdict, not mem or speed) at depth 81958.
  The LM Studio row's `wired_mb 17249` at depth 131072 is read at the
  edge of swap onset, not a clean steady state, per the row's own
  "pending" caveat.
- **Qwen3.8 blind.** The pair is the same model's last blind run at the
  same effort, on the MLX build (run 7, partial on a server failure).
  **87/100** 8/8, no bug defect.
- **Gemma-26B blind.** The pair is the same model's earlier blind run
  at q8_0 on the previous prompt version. **47.5/100** 8/8, one critical
  trap hit.
- **Bonsai guided, two invalid attempts.** Neither is an old row or a
  new row. The first attempt hit a harness fault: a dead `mlx_lm.server`
  by-hand restart cost the first three turns, then the model reached for
  `gh issue view 13`, hit HTTP 401 on this machine's invalid `gh` token,
  and looped on the interactive `gh auth login` the prompt forbids until
  `tooling_budget_exhausted` — zero commits, raw 27/100, `invalid: true`.
  Once the owner fixed `gh` auth, the retry (no penalty, a harness-fault
  retry per house rules) got stuck instead: 85 identical `ls`/`cat`
  calls in a row against a file that does not exist, zero commits, a
  `LOOP` verdict. The owner stopped it by hand at about three hours and
  asked to archive, not clean up, the worktree
  (`../mendel-bench-guided-prism-ml-Ternary-Bonsai-27B-mlx-2bit-off`) for
  inspection. Both rows are `invalid: true` in `results-guided.csv`.
  Bonsai's guided config has now failed twice for two different reasons;
  the owner is holding on a third attempt.
- **F3 deferred.** Qwen3.8-27B GGUF f16, effort medium, started
  calibration then was set aside for the next run at the owner's
  request. No score, no row.
- **Owner-added: Gemma-26B thinking off, Mendel.** Not in the original
  runbook. The owner noticed both existing blind rows for this model
  are thinking `high`, with no row at thinking `off` of any kind
  despite this run's own EvalPlus pass at `off`. The smoke passed; the
  guided run started, then the owner decided the whole gap (all four
  combinations of thinking on/off and guided/blind) belongs in run 11
  instead, done cleanly. The started guided attempt's worktree and
  branch were discarded, not archived. The same likely gap in
  Qwen3.6-35B-A3B is flagged, not acted on: its real ceiling after the
  run 9 compaction correction is only 8222 tokens, judged too small for
  a Mendel attempt before a `-c` fix.
- **Watcher trial verdict: did not fully match.** `run-watch.sh` and
  the sunset scripts agreed on every scoring run except one: Block C's
  EvalPlus run, where the sunset `liveness-watch.sh` called `SERVER
  DEAD` on a probe queued behind a live, slow turn, while `run-watch.sh`
  correctly waited for a second failed probe. Every Mendel run after
  that (Block C blind, Block E blind) matched cleanly. Since the run
  did not match end to end, `sunset/` is not deleted this run.
