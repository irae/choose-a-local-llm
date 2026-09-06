# Run 4 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. The site carried no row numbers yet at this point in
the project, so every old row below shows `—` for `#` rather than a
real number. No Mendel or Gates table applies to this run.

Quality:

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | — | Ternary-Bonsai-27B, GGUF, q4, thinking on (later split into single-slot and 2-slot rows) | 2x48k | speed | 14.9 → 7.9 | 10.0 GB | pending |
| new | — | Ternary-Bonsai-27B, GGUF, q4, thinking on | 2x48k | speed | 14.9 → 7.9 | 10.0 GB | **0.927/0.890/98%** |
| old | — | Gemma-4-12B, MLX³, thinking on (paused, resumes run 5) | 170k | engine | 37 → 31 | 8.8 GB | pending |
| new | — | Gemma-4-12B, MLX³, thinking on | 170k | engine | 37 → 31 | 8.8 GB | 0.741/0.722/— (directional, 54/164 attempted, 13 empty) |

Speed and context:

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | — | Gemma-4-12B, MLX³, thinking on | 170k | engine | 37 → 31 | 8.8 GB | pending |
| new | — | Gemma-4-12B, MLX³, thinking on | **158k*** | **mem** | 37 → **29.29** | 8.8 GB | pending |
| old | — | Gemma-4-12B, MLX³, thinking off | 170k | engine | 37 → 31 | 8.8 GB | 0.909/0.872/100% |
| new | — | Gemma-4-12B, MLX³, thinking off | **158k*** | **mem** | 37 → **29.29** | 8.8 GB | 0.909/0.872/100% |

- **New LM Studio ceiling criterion, the owner's decision.** The old
  170K figure came from an LM Studio engine bug (auto-fit stops at a
  fixed number, not a real memory or speed limit). The new rule: the
  ceiling is the onset of memory compression or swap in the watcher
  log, tok/s comes from the last clean step before it, and the context
  column keeps the auto-fit estimate, marked with an asterisk. For
  Gemma-12B: onset falls between 65K and 74K used tokens, last clean
  step 65,094 tokens at 29.29 tok/s. The old 170K/31 reading moved to
  `historical.md`, labeled superseded with the reason.
- **LM Studio forensics found context length is not controllable** for
  this model: every documented override path is ignored, auto-fit
  always lands at 158,464 tokens at the 24000 MB wired limit, thinking
  cannot be turned off on this engine build, and `--estimate-only`
  reports weights only and cannot be trusted. Full account:
  `hardware/m1-max-32gb/benchmarks/bench4/lmstudio-forensics.md`.
- **The prism fork's calibrated q4 KV bias does not cost quality.**
  0.927/0.890 at 4/164 empty beats the plain MLX 2-bit build
  (0.915/0.884) by a small margin.
- **Gemma-12B thinking-on EvalPlus stopped at 54/164**, directional
  numbers only (0.741/0.722 among attempted, 13 empty); resumes in
  run 5. The completion-percent field is `—` for this row: the
  164-problem formula does not apply to a run that has not finished
  attempting all 164.
- **Not yet run this night**: Qwen3.8-27B thinking-low, bonsai-off,
  Aider polyglot.
