# Local coding models on M1 Max 32 GB

Cross-model picks · llama-server (build 10621) + mlx-lm 0.31.3 · 2026-08-25, updated 2026-09-11

## Highlights

- **Best quality, and the model that finishes the agent task at its own
  default level:** Qwen3.8-27B. 0.988 base and 0.945 plus on EvalPlus
  across its 3-bit GGUF builds; on the Mendel blind task at effort
  xhigh the 4-bit GGUF scores 93 of 100 on a 65K window and the ISTA
  3-bit build 80.5 on a 147K window, both complete, one run each. Send
  hard problems to one of those rows.
- **Secondary-model pick, best big window, and best depth:** Gemma-26B
  on llama-server at f16 KV gives 60.3 tok/s at 4K and 17.3 at 197K,
  the largest context this machine loads for it; 0.976 / 0.945 / 100%
  on EvalPlus with thinking off, 47.5 of 100 on Mendel, complete.
  Gemma-12B with f16 KV and no drafter goes deeper still, 24.64 tok/s
  at 4K and still 8.86 at 245K, reaching the model's own 262,144
  window above the floor, in 13.9 GB.
- **Fastest shallow decode, and the KV type is a window-against-speed
  trade:** Qwen3.6-35B on llama. With f16 KV and no drafter it reads
  49.8 tok/s at 4K and 38.3 at 40K on real text, the largest window
  that loads; with q8_0 KV and its drafter the same files serve
  `-c 98304` and read 13.0 at 82K. EvalPlus 0.951 / 0.915 / 100% with
  thinking off; on the agent task 63 blind with thinking on and 50.5
  blind at thinking off.
- **Cheapest in memory, and most parallel:** Ternary Bonsai-27B gives
  27B-class quality from 8 GB of weights and the flattest curve of any
  model, but has never finished the agent task. On the prism fork it
  runs 2×48K slots at 9.8 tok/s each in 10.0 GB, the only setup that
  leaves the machine free, and at f16 KV the fork has no speed floor
  to 131K.
- **The rule that decides everything:** MLX runtimes barely slow down but
  hit hard memory ceilings. llama runtimes hold their speed deeper at f16
  KV, and their ceiling is the largest `-c` that loads; a published `-c`
  that OOMs at load is not a window.

## Models evaluated

<!-- gen:models-evaluated:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" top /> | 72k | mem | <TokCell shallow="11.8" deep="8.6" /> | <ScoreCell value="0.957/0.939" sub="96% completion" /> | <ScoreCell value="93" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" top /> | 72k | mem | <TokCell shallow="11.8" deep="8.6" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="87" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" top /> | 82k | speed | <TokCell shallow="43.7" deep="13.0" top-shallow /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="83" pill="mendel-guided" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" top /> | 147k | speed | <TokCell shallow="14.1" deep="8.3" stale /> | <ScoreCell value="0.945/0.921" sub="97% completion" /> | <ScoreCell value="80.5" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" top /> | 128k | mem | <TokCell shallow="15.1" deep="9.7" stale /> | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" /> | 147k | speed | <TokCell shallow="14.1" deep="8.3" stale /> | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" /> | 82k | speed | <TokCell shallow="43.7" deep="13.0" top-shallow /> | <ScoreCell value="0.951/0.915" sub="100% completion" /> | <ScoreCell value="62.5" pill="mendel-guided" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" /> | 66k | mem | <TokCell shallow="50.5" deep="33.6" stale top-shallow top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="50" pill="mendel-blind" /> |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" /> | 104k | mem | <TokCell shallow="15.8" deep="10.3" stale /> | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" /> | **197k** | mem | <TokCell shallow="60.3" deep="17.3" stale top-shallow top-deep /> | <ScoreCell value="0.884/0.860" sub="89% completion" /> | <ScoreCell value="47.5" pill="mendel-blind" /> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" /> | **245k** | mem | <TokCell shallow="24.64" deep="8.86" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" /> | 53k | mem | <TokCell shallow="24.5" deep="17.3" stale top-deep /> | <ScoreCell value="0.915/0.884" sub="97% completion" /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" /> | 33k | speed | <TokCell shallow="14.8" deep="7.9" stale /> | <ScoreCell value="0.927/0.890" sub="98% completion" /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" /> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" /> | 25k | mem | <TokCell shallow="17" deep="15.3" stale top-deep /> | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5" note="13%" pill="mendel-blind" /> |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-evaluated:end -->

¹ LM Studio's MLX engine, the only runtime that loads this model's
`gemma4_unified` architecture. It is retired here and no longer a
candidate; [the reasons are on its own page](./lmstudio-retired.md).

² PrismML's llama.cpp fork, an approved exception to the no-forks rule.

#### Legend

- **Ctx**, the usable context: the deepest context the config served
  above the floor, set by Cap. The coding harness gets the same
  window, rounded down to a multiple of 4096. On MLX the cell shows
  the harness window, 5 percent under the measured ceiling, because
  that runtime often triggers macOS memory compression near it.
- **Cap**, what stops the context from growing: memory holds the
  weights, the drafter, a vision adapter and the runtime's buffers,
  and what is left is context. Some models do not fit their trained
  window; others fit it and then decode too slowly to use. The floor
  is 8 tok/s. `mem` means memory ended the curve, whether the server
  did not load a larger context, died in flight, compacted or swapped,
  or the model's own trained window arrived first; the row note says
  which. `speed` means decode fell under the floor while memory still
  had room.
- **tok/s**, decode speed shallow, near an empty context, then deep,
  at Ctx. Most tools report the shallow number only, but engineering
  work and long documents run at depth, where speed falls. A drafter
  (MTP, speculative decoding) often changes the picture, and for some
  models it can help at one depth and hurt at another; nobody knows
  before measuring, so every drafter row is read on real text at
  more than one draft depth, with its acceptance.
- **EvalPlus**, scored once per model and thinking mode; runtimes
  serving the same model at a standard quant share the score, until a
  measurement says otherwise: Gemma-4-12B's GGUF Q4_K_XL scored 0.067
  above its LM Studio MLX 4-bit, and Gemma-4-26B-A4B's GGUF UD-Q4_K_XL
  at f16 KV scored 0.171 above its MLX 4-bit, so those pairs carry
  their own. Aggressive quants (for example the prism fork's
  calibrated q4 KV) never share; they pass the gate separately. Each
  run gets an output budget from a ten-problem calibration, capped at
  30000 tokens. A problem that runs to the cap counts as failed; the
  completion percentage says how many finished. The cap is what this
  machine can wait for, not the model's ceiling, so a capable model
  at a high reasoning level can lose points to it.
- **Coding**, a simulated pull request: the `pi` coding agent fixes a
  real issue in a real repository with known traps, over many turns,
  not one prompt. A stalled agent gets a fixed number of nudges; a
  nudge the model caused costs points. Mendel blind gives the terse
  issue and the model plans the work itself. Mendel guided gives the
  same task as steps with the traps disclosed, so a smaller model can
  serve as an executor rather than a planner. The pill names the
  test. Of the config's valid runs on the current prompt version the
  cell shows the one with the most libraries done, then the higher
  score; a muted percentage before the score is the share of
  libraries done when the run did not finish, `invalid` when every
  attempt was, `pending` when none ran. Never shared across levels or
  serving configs. Rows sort by the average of the EvalPlus base
  score and this one; a row with only one of the two sorts after
  every row with both. A single run carries about ten points of
  noise, so two rows within that are not separated. Every row's
  detail is in [the Mendel section](#mendel-agentic-quality-issue-13-bake-off).

All ceilings below are slow creeps. Rows measured from 2026-09-06 on
ran at wired limit 25000, the standing value; older rows ran at 24000
and say so in their config notes. See
[the measurement rules](../../methodology/context-creep) for why the
slow creep is more realistic than a fast sweep.

"Memory (at max ctx)" is the wired GPU memory the config holds at max ctx.

Server commands live in each model's report; aliases equal the pi model ids.
Compaction thresholds come from the floor table below, not from the window.

### Rows still being measured

Every row above has all three measurements: tok/s, EvalPlus and
Mendel. The rows below have at least one of the three
and are missing one or two; the same footnotes and sort apply, and
`#` continues the count. Rows with none of the three stay on their
model page.

<!-- gen:models-evaluated-partial:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" /> | 25k | mem | <TokCell shallow="17" deep="15.3" stale /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="not run" /> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" /> | **2x82k** | mem | <TokCell shallow="25.0" deep="15.7" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="f16" effort="off" /> | 4x49k | mem | <TokCell shallow="42.9" deep="27.7" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" effort="off" /> | 16k | speed | <TokCell shallow="13.8" deep="6.5" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" /> | 41k | mem | <TokCell shallow="69.1" deep="52.6" stale top-shallow top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" /> | 37k | mem | <TokCell shallow="55.1" deep="37.4" stale top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" /> | 53k | mem | <TokCell shallow="24.5" deep="17.3" stale /> | <ScoreCell value="0.927/0.902" sub="100% completion" /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" /> | 2x48k | speed | <TokCell shallow="14.9" deep="7.8" stale /> | <ScoreCell value="0.927/0.890" sub="98% completion" /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" /> | **2x82k** | mem | <TokCell shallow="66.6" deep="33.6" stale top-shallow top-deep /> | <ScoreCell value="0.884/0.860" sub="89% completion" /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" /> | **66k** | mem | <TokCell shallow="51" deep="12.8" stale /> | <ScoreCell value="0.713/0.701" sub="72% completion" /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" /> | **131k** | mem | <TokCell shallow="15.0" deep="9.7" stale /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" top /> |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-evaluated-partial:end -->

## Per-model reports

- [Qwen3.8-27B](./reports/qwen3.8-27b.md): strongest base model,
  slowest on this hardware; on llama at f16 KV it finishes the agent
  task at the model's own default, 93 blind on the 4-bit build and
  80.5 on the ISTA 3-bit build
- [Gemma-4-26B-A4B](./reports/gemma-4-26b-a4b.md): MoE+MTP, fastest
  Python, 197K at f16 KV on one slot, 47.5 blind on the agent task
- [Qwen3.6-35B-A3B](./reports/qwen3.6-35b-a3b.md): MoE+MTP, fastest JS,
  strongest base benchmarks; 41K at 53 tok/s with f16 KV, 82K at q8_0
- [Gemma-4-12B-it](./reports/gemma-4-12b-it.md): biggest context, best
  concurrency, 2×82K on llama f16
- [Ternary Bonsai-27B](./reports/bonsai-27b.md): 27B-class from 8 GB;
  two serving profiles (MLX speed / prism-fork desktop), 2 concurrent
  slots on the fork, no floor to 131K at f16 KV

## Decode speed vs used context — the 8 tok/s usability floor

Slow creeps. Rows dated 2026-09-06 or later ran at wired limit 25000:
the three Qwen3.6 rows, the Qwen3.8 GGUF rows, the Bonsai fork at f16
and the Gemma-12B two-slot row. The Gemma-26B rows, the Gemma-12B
one-slot rows, the Bonsai MLX row and the Qwen3.8 MLX row ran at 24000
between 2026-08-29 and 2026-09-05; the two speed-floored llama rows
keep the fast sweep of 2026-08-28.

| model / runtime | tok/s @ 4K | @ 16K | @ 32-33K | @ 49K | @ 74-90K | capped by | EvalPlus (base/plus/completion) |
|---|--:|--:|--:|--:|--:|---|--:|
| **Gemma-26B llama (f16 KV, MTP, `-c 212992`)** | 60.3 | 56.5 | 45.9 | 45.9 | 26.4 (115K), 17.3 (197K) | mem — 212992 is the largest `-c` that loads; 17.3 tok/s at 197K | 0.976/0.945/100% off, 0.884/0.860/89% on |
| **Gemma-26B MLX (f16 KV)** | 51.1 | 43.5 | 35.6 | 28.8 | 12.8 (70K) | mem — stable to 70K, 12.8 tok/s there | 0.713/0.701/72% |
| **Qwen3.6-35B MLX (f16 KV)** | 55.1 | 47.8 | 38.3 | | 37.4 (41K) | mem — stable to 41K, 37.4 tok/s there, then a Metal OOM | pending |
| Qwen3.6-35B llama (f16 KV, MTP, `-c 40960`) | 69.1 | 65.7 | 56.5 | | 52.6 (41K) | mem — 40960 is the largest `-c` that serves a real request; no ceiling found inside it; a creep with the drafter, a ceiling until read on real text | 0.951/0.915/100% off, 0.939/0.921/97% on |
| **Qwen3.6-35B llama (f16 KV, no drafter, `-c 40960`)** | 49.8 | | | | 38.3 (40K) | mem — 40960 is the largest `-c` that serves a real request; read on real text at the server's sampling | 0.951/0.915/100% off, 0.939/0.921/97% on |
| Qwen3.6-35B llama (q8_0 KV, MTP, `-c 98304`) | 43.7 | 31.2 | 19.6 | 19.2 | 11.2 (66K), 13.0 (82K) | speed — 7.86 at 98K, under the floor; zero swap; the 4K, 49K and 82K cells read on real text with acceptance 54 to 85 percent, the others are creep readings | 0.951/0.915/100% off, 0.939/0.921/97% on |
| Bonsai MLX (f16 KV) | 24.5 | 22.9 | 20.5 | 18.8 | 17.3 (58K) | mem — stable to 58K, 17.3 tok/s there | 0.915/0.884/97% |
| **Qwen3.8 llama Q4_K_M, bartowski (f16 KV, MTP, `-c 73728`)** | 11.8 | 16.1 | 16.4 | 15.0 | 8.6 (65.5K) | mem — 73728 is the largest `-c` that loads; the 4K and 65.5K cells read on real text with acceptance 37 to 63 percent, the others are creep readings | 0.982/0.939/100% (MLX score) |
| **Qwen3.8 llama IQ3_S-mtp, ISTA GSQ-RCO (f16 KV, no drafter, `-c 163840`)** | 14.1 | 13.3 | 12.4 | 11.5 | 10.2 (82K), 8.3 (147K) | speed — 8.30 at 147K, under the floor at 164K; zero swap | 0.976/0.933/99% low, 0.945/0.921/97% xhigh |
| Qwen3.8 llama IQ3_S-mtp, ISTA GSQ-RCO (f16 KV, MTP, `-c 131072`) | 15.1 | 14.7 | 13.7 | 12.7 | 11.0 (82K) | mem — clean to 114.7K at 9.7 tok/s | 0.976/0.945/99% |
| Qwen3.8 llama AD-IQ3_S, AtomicChat (f16 KV, MTP, `-c 106496`) | 15.8 | 14.8 | 13.7 | 12.7 | 11.0 (82K) | untested — swept to 98.3K at 10.3 tok/s and never hit a stop | 0.988/0.927/100% |
| Qwen3.8 MLX 4-bit (unquantized KV) | 17.1* | 16.4 | | | 15.3 (28K) | mem — stable to 28K, 15.3 tok/s there | 0.982/0.939/100% |
| **Bonsai prism fork (f16 KV, no drafter, `-c 131072`)** | 15.0 | 15.6 | 14.5 | 13.4 | 11.5 (82K) | untested — no floor found; 9.7 tok/s at 131K, the `-c` boundary itself | pending |
| Bonsai prism fork (q4_0 KV + bias) | 14.9 | 10.8 | 7.9 | | 7.9 (32K) | speed — under 8 tok/s at 32K, single slot deep, other slot idle-loaded | 0.927/0.890/98% |
| Gemma-12B llama (q8_0 KV, MTP) | 13.8 | 6.5 | | | | speed — under 8 tok/s at 16K | 0.976/0.939/100% |
| **Gemma-12B llama (f16 KV, no drafter)** | 24.6 | 22.7 | 20.6 | 18.8 | 8.86 (245K) | mem — 8.86 tok/s at 245K, where the trained window ends² | 0.976/0.939/100% |
| Gemma-12B llama (f16 KV, no drafter, 2 slots, `-c 196608`) | 25.0 | 22.8 | 20.6 | 18.6 | 15.7 (82K) | mem — swap grew at the step past 82K on every larger `-c`; 82K per slot is the ceiling | 0.976/0.939/100% |

Cells are blank past a config's cap, or where no step was measured at that depth.

The Gemma-12B curve on LM Studio is gone from this table. That runtime
is retired here, and its numbers stay on
[the model page](./reports/gemma-4-12b-it.md) with the reasons on
[the LM Studio page](./lmstudio-retired.md).

\*8K value.

² The Gemma-12B llama f16 curve was measured 2026-09-04, thinking off.
It ends where the model's trained window ends, with wired memory flat at
13.9 GB.

## Code quality — EvalPlus HumanEval+

| config | budget | pass@1 base | pass@1 plus | completion | status |
|---|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" top /> | 8886 | **0.988** | 0.927 | 100% | 0 empty, 3h10 |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" /> | 8192 | 0.982 | 0.939 | 100% | 0 empty; the 4-bit GGUF at medium carries this score and has no run of its own |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" /> | 8192 | 0.976 | **0.945** | 99% | 1 empty, 3h07 |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" /> | 8192 | 0.976 | 0.933 | 99% | 1 empty, 2h23; level with the medium row on base, one problem lower on plus |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" /> | 30000 | 0.945 | 0.921 | 97% | 5 empty, all at the 30000-token cap, about 9h43 active; below medium and low on both metrics |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" /> | 30000 | 0.957 | 0.939 | 96% | 6 empty, all at the cap, 8h30 active |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" top /> | 8192 | **0.976** | **0.945** | 100% | 0 empty, 19 minutes |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" /> | 30000 | 0.884 | 0.860 | 89% | 18/164 empty, thinking non-convergence |
| <ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" /> | 30000 | 0.713 | 0.701 | 72% | 46/164 empty, the convergence problem at its worst |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" top /> | 8192 | **0.976** | **0.939** | 100% | 0 empty |
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" /> | 30000 | 0.909 | 0.872 | 100% | 0 empty; 0.067 under the GGUF quant, so the two do not share a score |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" top /> | 8192 | **0.951** | 0.915 | 100% | 0 empty, 15 minutes |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" /> | 26624 | 0.939 | **0.921** | 97% | 5/164 empty is a real model ceiling |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" top /> | 10240 | **0.915** | **0.884** | 97% | 5/164 empty is a real model ceiling |

## Mendel — agentic quality (issue-13 bake-off)

Two independent tests of the same task (rubric unchanged, everything
else different; never compare a score across them): **blind** (terse
prompt, the model must find the traps itself) and **guided** (numbered
workflow, traps disclosed, tests instruction-following instead of trap
discovery). Full rubric, scoring method, and the rest of the field
(proprietary and other local models) live in the open-source
[Mendel benchmark](https://github.com/irae/mendel/tree/benchmark).

Current rows use blind prompt v1.1 and guided v3.0, run from fresh
base tags with the tap crash fix. Rows from older prompt versions
moved to [historical](./historical.md); never compare across prompt
versions.

Scores wear a completion cap: a score cannot exceed the fraction of
the task that got done (`min(raw, 100 × done/8)`). A partial run that
the model itself spoiled can run again, but the new row loses 10
points for each earlier valid attempt. When our own harness caused the
stop, the corrected re-run carries no penalty. Runs where a serving
failure prevented any real work are invalid and not listed here; the
hosted reports show them dimmed, with reasons.

Every row ran under the same harness, pi, which is pluggable and
configurable and serves every model the same way, the cloud baselines
included. "Ctx" is the context window the harness had for the run.

| model | test | runtime | thinking | max ctx | score | status |
|---|---|---|---|--:|--:|---|
| Qwen3.8-27B | blind | GGUF Q4_K_M bartowski, f16 KV | effort medium | 49k | **87/100**‡ | complete, all 8 libraries; no bug defect. Harness reserve 16384 |
| Qwen3.6-35B-A3B | guided | GGUF, q8_0 KV | high | 120k | **83/100**‡⏳ | complete, all 8 libraries |
| Qwen3.8-27B | blind | GGUF IQ3_S-mtp ISTA, f16 KV, no drafter | effort xhigh | 147k | **80.5/100** | complete, all 8 libraries; one critical runtime defect (trap A). The model's own default level. Harness reserve 8192 |
| Qwen3.8-27B | blind | GGUF IQ3_S-mtp ISTA, f16 KV | effort medium | 115k | **76.5/100** | complete, all 8 libraries; one critical runtime defect (trap A). Harness reserve 8192 |
| Qwen3.8-27B | blind | GGUF Q4_K_M bartowski, f16 KV | effort medium | 66k | **76/100** | complete, all 8 libraries; one critical runtime defect (trap A). Harness reserve 8192 |
| Qwen3.8-27B | blind | GGUF IQ3_S-mtp ISTA, f16 KV, no drafter | effort low | 147k | **66/100** | partial, 7/8 libraries; two runtime defects (traps A and C). Ended on the harness's 25-minute turn cap during a test suite |
| Qwen3.6-35B-A3B | blind | GGUF, q8_0 KV | high | 98k | **63/100** | complete, all 8 libraries; one critical runtime defect (trap A) |
| Qwen3.6-35B-A3B | guided | GGUF, q8_0 KV | off | 80k | **62.5/100** | complete, all 8 libraries |
| Gemma-4-26B-A4B | guided | GGUF, f16 KV | high | 208k | **57/100** | partial, 7/8 libraries; third attempt, the first two killed by a system memory squeeze |
| Gemma-4-26B-A4B | blind | GGUF, f16 KV | high | 213k | **47.5/100**‡ | complete, all 8 libraries; one critical runtime defect (trap A) |
| Qwen3.6-35B-A3B | guided | GGUF, q8_0 KV | off | 48k | **46.5/100** | complete, all 8 libraries; twelve compactions on a window the creep does not support |
| Gemma-4-12B | guided | GGUF, f16 KV, no drafter | off | 262k | **37.5/100** | partial, 3/8 libraries; model budget exhausted after three nudges |
| Ternary Bonsai-27B | blind | MLX 2-bit | high | 58k | **37.5/100** (raw 55) | partial, 300-min wall clock at 3/8 libraries |
| Qwen3.8-27B | blind | GGUF AD-IQ3_S AtomicChat, f16 KV | effort medium | 98k | **37.5/100** (raw 74) | partial, 3/8 libraries; ended on a repetition loop, the model's own failure |
| Ternary Bonsai-27B | guided | GGUF², q4 KV | high | 64k | **31.5/100** | partial, 3/8 libraries; 300-min wall clock, stopped by hand at 469 minutes |
| Gemma-4-26B-A4B | guided | GGUF, f16 KV | off | 208k | **25/100** (raw 44) | partial, 2/8 libraries; ended on the live loop stop, five identical edit calls |
| Qwen3.8-27B | blind | MLX 4-bit | effort low | 26k | **12.5/100** (raw 67.5) | partial, 1/8; the 26624-token window plus a 16384-token output budget forced premature stops (our config arithmetic, not the model) |
| Ternary Bonsai-27B | guided | MLX 2-bit | high | 58k | **12.5/100** (raw 59) | partial, 300-min wall clock at 1/8 libraries |
| Ternary Bonsai-27B | blind | GGUF², q4 KV | high | 64k | **12.5/100** (raw 60.5) | 1/8 libraries; typoed the repo path, self-scoped to chalk; a penalized retry is pending |
| Ternary Bonsai-27B | guided | GGUF², f16 KV, no drafter | high | 131k | **12.5/100** (raw 36) | partial, 1/8 libraries; 376 tool calls and 74 tool errors at a 127k peak context |
| Gemma-4-26B-A4B | blind | GGUF, f16 KV | off | 208k | **12.5/100** (raw 21) | partial, 1/8 libraries; ended on the live loop stop, five identical edit calls |

**Effort xhigh beats low on Qwen3.8, and spends less doing it.** On the
same build, the same window and the same reserve, xhigh scored 80.5
with all eight libraries in 109 minutes at a 118K peak context; low
scored 66 with seven in 163 minutes at 130K, and ended on the turn cap.
Both rows record their sampling: temperature 1.0, top_p 0.95, the
values the server reads from the model file.

⏳ Pending a re-run, low priority. This row ran on a 120K harness
window; at wired 25000 the q8_0 arm serves `-c 98304`, so the window
is out of reach. The score stands as a record. See
[the wired limit](./index.md#the-wired-limit-25000).

‡ Scheduled for a re-run. These rows compacted under the harness's
old reserve of 16384 tokens, twice the answer budget; since 2026-09-06
the harness reserves 8192, so each gets a fresh row under the current
setting and keeps this one until then. The Qwen3.8 row ran at effort
medium, which that model is no longer run at; its fresh row is the
4-bit build at effort xhigh, not yet run.

Invalid, not scored as model quality: three Gemma-4-12B runs on the
retired LM Studio entry (thinking on, repetition loop, zero commits);
the Qwen3.8-27B MLX guided runs (Metal OOM crashes past the 26624-token
window, zero commits); two Bonsai MLX guided runs at thinking off (a
dead `gh` token, then an 85-call identical-command loop).

Full tables for both Mendel tests are on the
[Mendel page](./benchmarks/mendel.md), and the complete reports are
hosted here: <a href="../../mendel/report.html" target="_blank" rel="noreferrer">blind</a> ·
<a href="../../mendel/report-guided.html" target="_blank" rel="noreferrer">guided</a>.

**The window decides the agent task on dense Qwen3.8.** The task needs
about 46K of context. The GGUF at f16 KV holds 49K and finished it at
87; the MLX build holds 26K, kept stopping at 1 output token as the
prompt neared its window, and its guided runs hit the Metal OOM
dead-thread trap three times. Its scores above carry that caveat. On
Qwen3.6 the same rule showed as 16 points: 62.5 on the window its
creep supports against 46.5 on a smaller one that compacted twelve
times.

**Gemma-26B finishes the task at thinking high and loops at thinking
off.** Blind at high it touched all eight libraries and lost most of
its points to one critical trap and leftover calls; guided at high it
did seven of eight. Both thinking-off rows ended on five identical edit
calls, caught by the live loop stop in under half an hour each. Its
earlier blind row at q8_0 KV scored 38, partial, on the previous prompt
version.

**Gemma-12B on llama-server ran out of budget, not of ability.** Three
of eight libraries in the guided run, then the model budget after three
nudges, the same signature as its retired LM Studio entry. The three
LM Studio rows measure a serving failure, not the model's coding: the
entry always thinks, fell into a repetition loop after its first failed
edit in every run, and committed nothing. The evidence is on
[the Gemma-12B data page](./benchmarks/gemma-4-12b-it.md#the-retired-entry).

**Both Bonsai mlx rows ran at thinking high, not the requested low.**
The runner asked for low, but the session logs record high; the flag
was not honored on `mlx_lm.server`. The rows are scored and labeled at
the observed level. Bonsai's blind run finished 3 of 8 libraries and
lost about 40 minutes to one JSON syntax break of its own making; it
ended on the 300-minute wall clock, not on the rubric.

## Open questions

- The 4-bit Qwen3.8 GGUF's own EvalPlus score and its agent row at effort
  xhigh; the Bonsai fork's EvalPlus score at f16 KV; a thinking-on
  score for Gemma-12B; Qwen3.6 blind at thinking off on the 81920
  window.
- A Bonsai guided row at thinking off. Two attempts went invalid on
  the harness; the third waits on a live loop alarm in the runner.
- The Bonsai prism-fork q4 pick, and the corpus behind its KV bias file.
- **Qwen3-Coder-30B-A3B is the only promising untested contender.** Not on
  this machine yet. Community-reported EvalPlus HumanEval+ 0.902 (unverified
  by our gate); MoE, 3.3B active, GGUF Q4_K_M ~18.6 GB. Math projects its
  GGUF single-slot ceiling above 45K, but its 2-slot ceiling lands close to
  our 45K bar either way; likely below our best score. Worth a real test
  before ruling it out, low priority otherwise.
- Watch list: brew llama.cpp reading ternary Q2; mlx-lm gaining
  `gemma4_unified` and server-side KV quantization; LM Studio's MLX
  continuous batching (mlx-engine, general since 0.4.2, confirmed here at
  0.4.21) as the only path to real multi-slot MLX serving. Plain
  `mlx_lm.server` has no shared-weight multi-slot mode, so MLX 2-slot
  math does not apply to it the way GGUF's does.

## History and reasoning

**Why the depth axis exists at all.** Decode speed falls as the KV cache
fills. A real coding session measured 1.7 tok/s at 135K used tokens, on a
config whose near-empty benchmark said 62. Context maxima alone are storage,
not speed. So each model is swept with an append-only growing prompt, which
gives perfect cache reuse, until decode drops under the 8 tok/s floor or the
server runs out of memory. The floor, not the window, is where the harness
compaction threshold belongs.

**How to read the numbers.** Sweep prompts are synthetic code continuations,
so MTP-model numbers read below the standard py/js bench, because draft
acceptance differs. The curves stay comparable across rows. Scores are
HumanEval+ pass@1, one score per model and thinking mode (footnote ²
above).

**Quality scores need a calibrated output budget.** A fixed budget that is
too small lets reasoning exhaust the cap, and empty completions score as
failures, a harness flaw, not a model flaw. Budgets here are calibrated per
model from measured reasoning length. Superseded scores from an
uncalibrated budget live on [the historical page](./historical.md), never
here.

**The Gemma models have a real convergence problem with thinking on.**
Their thinking mode sometimes fails to converge at all, 30K tokens of
reasoning with no answer. That is model behavior, not a harness limit;
the 26B does it on 11% of the problems on the GGUF and 28% on the MLX
build, and thinking off removes it.

Superseded measurements live in
[the historical page](./historical.md). Nothing on this page
was measured under a retired wired limit. The flow is in the
[methodology](../../methodology.md).

---

Method: warmup before measurements; identical prompts across models;
temperature 0. Per-model raw numbers in the benchmarks pages.
