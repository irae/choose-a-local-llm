# Qwen3.8-27B Q4_K_M (bartowski)

File: [`bartowski/Qwen3.8-27B-GGUF`](https://huggingface.co/bartowski/Qwen3.8-27B-GGUF),
`Qwen3.8-27B-Q4_K_M.gguf`, revision `f0eec4a`, about 17 GB, a 4-bit
k-quant with a built-in MTP head. Server: llama-server, f16 KV on the
M1 Max 32 GB. Every run of this file on every machine is on this page,
retired and superseded rows included; a run a harness or serving
defect voided is not.

- **Why it is here.** The first Qwen3.8-27B GGUF file on the M1 Max
  32 GB, the dense k-quant control for the MLX build and, later, for
  the 3-bit candidates.
- **What it settled.** The MTP drafter loses on this file on real
  text at every depth, so it serves without one. Effort xhigh scores
  higher than medium on both EvalPlus and the agent task, and leads
  every local row on the agent task at 93.
- **Where it stands.** Blind 93/100 at effort xhigh on a 65536 window,
  measured 2026-09-11, the highest Mendel score of any local row on
  the M1 Max 32 GB.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" top /> | **72k** | <TokCell shallow="12.4" deep="9.7" cap="mem" top-shallow top-deep /> | **25.0 GB** | <ScoreCell value="0.982/0.951" sub="100% completion" top /> | <ScoreCell value="93" pill="mendel-blind" top /> | <span title="EvalPlus 5h04 · Mendel 3h33"><b>8h38</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" top /> | **72k** | <TokCell shallow="12.4" deep="9.7" cap="mem" top-shallow top-deep /> | **25.0 GB** | <ScoreCell value="0.982/0.939†" sub="100% completion" top /> | <ScoreCell value="87" pill="mendel-blind" top /> | <span title="EvalPlus 3h32 · Mendel 2h09"><b>5h42</b></span> |
<!-- gen:binary-rows:end -->

<!-- gen:binary-best-preset:start -->
Best configuration on this page, as a section of `hardware/kamaji/models.ini` (M1 Max 32 GB, llama-server, pi id `qwen3.8-27b`). Every preset of this page: [`qwen3.8-27b`](#preset-qwen3-8-27b).

```ini
[qwen3.8-27b]
hf = bartowski/Qwen3.8-27B-GGUF:Q4_K_M
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 73728
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:binary-best-preset:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8192 | 16384 | <ScoreCell value="0.982/0.951" sub="100% completion" top /> | none | 9/164 | <TokCell shallow="12.4" deep="9.7" /> | 5h04 |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 30000† | 32048 | <ScoreCell value="0.982/0.951" sub="100% completion" /> | none | 3/164 | <TokCell shallow="12.4" deep="9.7" /> | 7h29 |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | —† | 30000 | <ScoreCell value="0.957/0.939" sub="96% completion" /> | 6 budget | — | <TokCell shallow="12.4" deep="9.7" /> | 8h30 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:binary-evalplus:end -->

The medium row's EvalPlus score is the MLX effort-medium run, carried
by the shared-score rule; this build has no full EvalPlus of its own
at medium. The xhigh row's six empties are all completions that hit
the 30000-token budget cap.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" /> | blind-v1.1 | 64k | **93** | 8/8/done | 213.3 | 10,077k | 62k | 3 | 272 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" /> | blind-v1.1 | 48k | **87** | 8/8/done | 129.3 | 5,947k | 46k | 4 | 210 | 10 |  |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" /> | blind-v1.1 | 64k | **76** | 8/8/done | 97.8 | 5,008k | 60k | 1 | 173 | 12 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The medium row's 87/100 (reserve 16384, window 49152) and its
2026-09-08 re-run at 76/100 (reserve 8192, window 65536) are two
different configurations, not a repeat; the second failed trap A,
which the first passed. Qwen3.8-27B is never run at effort medium
since 2026-09-09 (owner rule, `benchmarks/PLANNING.md`). Every medium
row keeps its numbers as a record, with no re-run.

## Speed and context

Measured on the M1 Max 32 GB, the only machine that served this file.

<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| ladder | 2026-08-28 | q8_0 KV, `-c` 32768, limit 25000 | 14.1 tok/s at 4K, 7.3 at 24.5K, under the 8 tok/s floor |
| ladder | 2026-09-08 | MTP n-max 3, `-c` 73728, wired limit 25000 | `-c 73728` serves, `-c 81920` OOMs at load; decode and draft acceptance flat across the served range |
| MTP creep, real text (benchy) | 2026-09-11 | MTP n-max 3, f16 KV, `-c 73728` | 11.8 tok/s at 4K, 8.6 at 65.5K, 37 to 63 percent acceptance |
| no-drafter benchy | 2026-09-13 | no drafter, f16 KV, `-c 73728` | 12.4 tok/s at 4K, 9.7 at 65.5K, above the drafter arm at both depths |

The full curves, including the context ramp measured at the retired
27000 wired limit (f16 KV, MTP n-max 3: `-c 98304` clean at 24.1 GB,
`-c 106496` Metal OOM), are on
[the benchmarks page](../setups/kamaji/benchmarks/qwen3.8-27b.md).

## Server presets

<!-- gen:binary-presets:start -->
### `qwen3.8-27b` {#preset-qwen3-8-27b}

M1 Max 32 GB, a section of `hardware/kamaji/models.ini` (llama-server).

```ini
[qwen3.8-27b]
hf = bartowski/Qwen3.8-27B-GGUF:Q4_K_M
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 73728
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:binary-presets:end -->

## Log

- 2026-08-27 to 2026-08-28 — The first EvalPlus block scored the MLX
  4-bit build at effort medium instead of this GGUF build, so this
  file's own medium score is the shared MLX result, not a run of its
  own. The context ramp of that era, at the retired 27000 wired limit,
  stands as a record on
  [the historical page](../setups/kamaji/historical.md).
  `hardware/kamaji/benchmarks/bench1/`.
- 2026-09-07 to 2026-09-09 — Full gate at effort medium: ladder and
  creep at wired limit 25000 (`-c 73728` serves, `-c 81920` OOMs at
  load); Mendel blind at reserve 16384 and window 49152 (87/100), and
  a re-run at reserve 8192 and window 65536 (76/100), which failed
  trap A. `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-09 — The owner banned effort medium on Qwen3.8-27B. Every
  medium row keeps its numbers as a record, with no re-run.
  `benchmarks/PLANNING.md`.
- 2026-09-11 — Draft-depth sweep on real text (llama-benchy): the MTP
  drafter at n-max 3 reads 11.8 tok/s at 4K and 8.6 at 65.5K, 37 to 63
  percent acceptance, 40 percent under the creep and slower at 4K than
  the ISTA 3-bit build with no drafter. Mendel blind at effort xhigh:
  93/100, complete 8/8, on the 65536 window, the highest Mendel score
  of any local row. `hardware/kamaji/benchmarks/bench14/`.
- 2026-09-11 to 2026-09-12 — EvalPlus at effort xhigh, budget 30000:
  0.957/0.939, six empty, every one a completion that hit the 30000
  cap, 8h30 active wall time; above the ISTA build's 0.945/0.921 at
  the same level. `hardware/kamaji/benchmarks/bench15/`.
- 2026-09-12 to 2026-09-13 — Real-text speed with llama-benchy, no
  drafter: 12.4 tok/s at 4K and 9.7 at 65.5K, above the drafter arm at
  both depths; the served command drops the drafter.
  `hardware/kamaji/benchmarks/bench16/`.
- 2026-09-16 to 2026-09-17 — M1 Max: the thinking-budget test, effort
  xhigh, f16 KV, MTP n-max 3. The calibration's longest converged
  reasoning ran 22947 tokens, so the thinking budget sits at the 30000
  cap. The budgeted full run: 0.982 / 0.951, no empty answer, 3 forced
  answers and all 3 pass, 447.8 minutes, against 0.957 / 0.939 with 6
  empties in 510.3 minutes without the budget. The one forced answer
  that failed the plus tests hits the cap without the budget too, so
  the budget stands. `hardware/kamaji/benchmarks/bench22/`.
