# Qwen3.6-35B-A3B UD-Q4_K_XL (unsloth) on M1 Max 32 GB

File: [`unsloth/Qwen3.6-35B-A3B-MTP-GGUF`](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF),
`Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf`, revision `5bc3e23` on the runs that
record one, about 20 GB, with an MTP head embedded. Server:
llama-server, KV type f16 or q8_0 depending on the arm. Every run of
this file on this machine is on this page, retired and superseded rows
included; a run a harness or serving defect voided is not.

- **Why it is here.** The first Qwen3.6 file measured on this machine,
  and the machine's deep-context MoE candidate: 35B total parameters
  with about 3B active per token, trained context 262144.
- **What it settled.** The MTP drafter fails to allocate on the
  current brew llama.cpp build and several arms now serve without it.
  Without the drafter, the f16 KV arm holds a window 60 percent larger
  than the q8_0-with-drafter arm (65536 against 40960). Thinking off
  beats thinking on on EvalPlus with a smaller budget, and the Mendel
  harness window decides the score directly: the same config scored
  46.5 on a frozen 49152-token window and 62.5 on the 81920-token
  window its own creep supports.
- **Where it stands.** EvalPlus at thinking on: 0.957/0.939, budget
  26624, both remaining empties proven as the output cap. Best Mendel
  row: guided, thinking off, 62.5/100 complete on the 81920 window.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" top /> | **82k** | speed | <TokCell shallow="43.7" deep="13.0" /> | 25.6 GB | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 5h02 · Mendel 1h32">6h33</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" top /> | **82k** | speed | <TokCell shallow="43.7" deep="13.0" /> | 25.6 GB | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | <ScoreCell value="62.5" pill="mendel-guided" top /> | <span title="EvalPlus 0h15 · Mendel 1h29">1h44</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" top /> | **66k** | mem | <TokCell shallow="50.5" deep="33.6" stale top-shallow top-deep /> | **25.0 GB** | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="50" pill="mendel-blind" /> | <span title="EvalPlus 5h02 · Mendel 0h33">5h35</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" /> | 41k | mem | <TokCell shallow="69.1" deep="52.6" stale top-shallow top-deep /> | **25.1 GB** | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h02 · Mendel —">5h02†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" />](../benchmarks/qwen3.6-35b-a3b.md) | 26624 | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | 2 budget | <TokCell shallow="43.7" deep="13.0" /> | 5h02 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" />](../benchmarks/qwen3.6-35b-a3b.md) | 8192 | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | none | <TokCell shallow="43.7" deep="13.0" /> | 0h15 |
<!-- gen:binary-evalplus:end -->

Both empties left on the thinking-on row are the output budget, not a
model stop: a re-run of the empty problems on 2026-09-16 proved the cause.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" /> | blind-v1.1 | 96k | **63** | 8/8/done | 79.2 | 7,933k | 94k | 0 | 203 | 13 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" /> | blind-v1.1 | 80k | **50.5** | 8/8/done | 40.0 | 6,996k | 98k | 2 | 190 | 10 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" /> | blind-v1.1 | 64k | **50** | 8/8/done | 33.0 | 7,344k | 61k | 2 | 211 | 13 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" /> | blind-v1.0 | 96k | **41.5** | 8/8/done | 132.0 | 10,090k | 94k | 1 | 258 | 13 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" /> | guided-v3.0 | 112k | **83** | 8/8/done | 91.9 | 12,712k | 94k | 1 | 285 | 16 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" /> | guided-v2.1 | 96k | **65.5** | 8/8/done | 75.6 | 12,081k | 94k | 0 | 251 | 8 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" /> | guided-v3.0 | 80k | **62.5** | 8/8/done | 89.4 | 13,045k | 78k | 1 | 264 | 16 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" /> | guided-v3.0 | 48k | **46.5** | 8/8/done | 95.6 | 9,473k | 52k | 12 | 299 | 7 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The window cell is the harness context window of that run. The same
config's two guided rows at thinking off (46.5 on a 49152-token window,
twelve compactions; 62.5 on the 81920-token window with one
compaction) show the window deciding the score, not the model. Every
blind row that finished carries a critical trap: `fs.promises.glob()`
returns an AsyncIterator, and every run's `.then()` call on it throws.

## Speed and context

<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" hide="drafter,kv,effort" />

| measurement | date | config | result |
|---|---|---|---|
| MTP sweep | 2026-08-27 | 32K context, f16 KV, n-max 0 to 4 | peak at n-max 3: 68.21 tok/s py (82% acceptance), 73.53 tok/s js (90%); off baseline 52.34/52.41 |
| ladder and creep | 2026-09-11 | f16 KV, no drafter, wired limit 25000, `-c 65536` | serves a real completion at 25027 MB wired; creep ran clean to 65578 tokens at 33.64 tok/s, no ceiling found |
| real text, llama-benchy | 2026-09-11 | q8_0 KV, drafter n-max 3, `-c 98304`, wired limit 25000 | 43.68 tok/s at 4K, 19.23 at 49K, 13.01 at 82K; acceptance 54 to 85 percent |
| real text, llama-benchy | 2026-09-11 | f16 KV, no drafter, `-c 40960`, wired limit 25000 | 49.80 tok/s at 4K, 38.26 at 40K; within four percent of the creep |
| vision, projector loaded | 2026-09-11 | f16 KV, `-c 65536`, wired limit 25000 | 1400-pixel page costs 7005 prompt tokens; drafter works beside the projector only at n-max 1, ahead of the model card |

The full curves, including the retired 24000 and 27000 wired-limit
tables, are on [the benchmarks page](../benchmarks/qwen3.6-35b-a3b.md)
and [the historical page](../historical.md).

## Log

- 2026-08-27 — MTP sweep at 32K context, f16 KV: peak at n-max 3, 68.21
  tok/s py (82% acceptance) and 73.53 tok/s js (90%), ahead of the
  no-drafter baseline of about 52 tok/s both ways. The fixed 3072-token
  output budget was found flawed the same run: reasoning could exhaust
  the cap and score an empty completion as a failure, so this run's
  EvalPlus reading is a lower bound. `hardware/kamaji/benchmarks/bench1/`.
- 2026-08-28 — The budget-calibration method introduced (10 fixed
  problems, 30K cap, budget = observed max times 1.5). At the
  calibrated budget of 26624 tokens this config scored 0.957/0.939/99%
  with 2 empty, recovering 56 missing or empty completions from the
  flawed 3072-cap pass (0.610/0.610/62%, 62 of 164 empty).
  `hardware/kamaji/benchmarks/bench2/`.
- 2026-08-30 to 2026-08-31 — Mendel guided row (prompt v2.1): 67.5/100,
  partial. The MTP drafter fails to allocate on the current brew
  llama.cpp build: the backend returns HTTP 500 on every request while
  `/health` stays ready. The guided run served without the drafter; a
  re-check was planned for the next run. `hardware/kamaji/benchmarks/bench5/`.
- 2026-09-01 — The planned drafter re-check deferred to the next run
  on the owner's decision; the run closed after its own EvalPlus block
  without touching this file. `hardware/kamaji/benchmarks/bench6/`.
- 2026-09-01 to 2026-09-03 — Served with no MTP drafter flags, per the
  runbook. Mendel blind (prompt v1.0) scored 41.5/100, complete. Mendel
  guided (prompt v2.1) scored 65.5/100, complete, all 8 libraries, 75.6
  minutes. `hardware/kamaji/benchmarks/bench7/`.
- 2026-09-05 to 2026-09-06 — Thinking off scored on EvalPlus for the
  first time: 0.951/0.915/100%, 0 empty, ahead of the thinking-on
  sibling's 0.939/0.921/97% at the same budget.
  `hardware/kamaji/benchmarks/bench10/`.
- 2026-09-06 to 2026-09-07 — Every missing Mendel row filled at the
  trial wired limit 25000, opened by this file's own depth creep.
  Guided at thinking off scored 46.5 on a frozen 49152-token window
  with twelve compactions, then 62.5 on the 81920-token window the
  creep supports, complete; the rule that measured parameters come
  from the newest measurement came out of this file. The f16 KV arm
  now loads `-c 40960`, which it did not at the retired 24000 limit.
  `hardware/kamaji/benchmarks/bench11/`.
- 2026-09-11 — Real-text speed with `llama-benchy` at the server's own
  sampling: the q8_0 drafter arm reads 43.7 tok/s at 4K down to 13.0 at
  82K (54 to 85 percent acceptance); the f16 no-drafter arm reads 49.8
  at 4K and 38.3 at 40K. Mendel blind at thinking off scored 50.5/100,
  complete 8/8, on the 81920 window, one critical trap missed; sampling
  (temperature 1.0, top_p 0.95) recorded for the first time.
  `hardware/kamaji/benchmarks/bench14/`.
- 2026-09-11 — The f16 KV arm without its drafter laddered and
  creeped at wired limit 25000: `-c 65536` serves, and the creep ran
  clean to 65578 tokens at 33.6 tok/s with no ceiling found, a window
  60 percent larger than the drafter arm's 40960. Mendel blind at
  thinking on scored 50/100, complete 8/8, on the 65536 window, two
  compactions, one critical trap missed, 33 minutes. With the vision
  projector loaded, the same server still serves `-c 65536`; one
  1400-pixel page costs 7005 prompt tokens, and the drafter works
  beside the projector only at n-max 1, against the model card, and
  wins at every depth measured. `hardware/kamaji/benchmarks/bench15/`.
- 2026-09-12 to 2026-09-13 — Real-text speed re-read against the
  depth creep on every no-drafter arm; this file's rows matched within
  four percent. `hardware/kamaji/benchmarks/bench16/`.
- 2026-09-15 to 2026-09-16 — Re-run of the empty EvalPlus problems:
  both empties on the thinking-on row are the output budget, none a
  model stop. Thinking-on score moved to 0.957/0.939.
  `hardware/kamaji/benchmarks/bench20/`.
- Historical — rows at the retired 24000 and 27000 wired limits. At
  24000: f16 KV served only `-c 33792` (33920 OOMs), and q8_0 KV
  served `-c 40960` in practice (49920 passed a one-token probe, then
  OOM'd on the first real step). At 27000 (retired for making the
  machine too slow for normal use): q8_0 KV served `-c 212992` single
  session and `2×96K` across two slots; f16 KV served 136K single
  session. Superseded by the 25000-limit rows above.
  [The historical page](../historical.md).
