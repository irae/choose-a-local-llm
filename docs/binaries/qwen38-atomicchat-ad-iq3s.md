# Qwen3.8-27B AD-IQ3_S (AtomicChat)

File: [`AtomicChat/Qwen3.8-27B-GGUF`](https://huggingface.co/AtomicChat/Qwen3.8-27B-GGUF),
`AD-IQ3_S`, revision `ca10ebc`, about 13.84 GB, an "Atomic Dynamic"
3-bit layout with extra bits on the attention gate and the state
output path. Server: llama-server, f16 KV on the M1 Max 32 GB, the
only machine that served it. Every run
of this file on every machine is on this page, retired and superseded
rows included; a run a harness or serving defect voided is not.

- **Why it is here.** One of three 3-bit candidates picked for the
  12 GB budget on 2026-09-07, chosen because it drifts 18 percent less
  from BF16 than the unsloth candidate at almost the same size, by the
  publisher's own KLD measurement (0.0325 against 0.0397 mean KLD).
- **What it settled.** The MTP drafter loses at every depth on real
  text, so it serves without one. It holds the project's best single-
  turn base score, 0.988, at effort medium. Qwen3.8-27B is never run
  at effort medium since 2026-09-09 (owner rule,
  `benchmarks/PLANNING.md`), so every row on this page keeps its
  numbers as a record, with no re-run.
- **Where it stands.** Blind 37.5 of 100 (capped from 74 raw) at
  effort medium on a 98304 window, measured 2026-09-09; it ended on a
  repetition loop after three of eight libraries. No xhigh or low row
  exists.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-atomicchat-ad-iq3s" top /> | **104k** | <TokCell shallow="14.3" deep="9.6" cap="mem" top-shallow top-deep /> | **24.1 GB** | <ScoreCell value="0.988/0.927†" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 3h11 · Mendel 1h00"><b>4h10</b></span> |
<!-- gen:binary-rows:end -->

<!-- gen:binary-best-preset:start -->
Best configuration on this page, as a section of `hardware/kamaji/models.ini` (M1 Max 32 GB, llama-server, pi id `qwen3.8-27b`). Every preset of this page: [`qwen3.8-27b`](#preset-qwen3-8-27b).

```ini
[qwen3.8-27b]
hf = AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 106496
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
| [<ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-atomicchat-ad-iq3s" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | —† | 8886 | <ScoreCell value="0.988/0.927" sub="100% completion" /> | none | — | <TokCell shallow="14.3" deep="9.6" /> | 3h11 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:binary-evalplus:end -->

No empty completions on this file's only EvalPlus run (0/164 at
budget 8886).

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-atomicchat-ad-iq3s" /> | blind-v1.1 | 96k | **37.5** | 3/8/partial | 59.8 | 7,025k | 70k | 0 | 189 | 7 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The row ended on a repetition loop: five identical `bash` searches of
a directory that held nothing the model wanted. The pi harness's own
live detector caught it; `loop-check.py`'s 60-line sliding window
missed it, a tool gap filed for the coordinator and not fixed
mid-run. The run's own tables call the row invalid and count no
score; the 37.5 shown here is the capped partial score the site row
carries.

## Speed and context

Measured on the M1 Max 32 GB, the only machine that served this file.

<ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| creep | 2026-09-07 to 2026-09-08 | f16 KV, MTP n-max 3, wired 25000, `-c 106496` | 98338 tokens at 10.26 tok/s, no stop condition hit — a list end, not a measured ceiling |
| n-max sweep, one 1024-token completion each | 2026-09-09 | f16 KV, `-c 4096`, temperature 0, n-max 4 and 6 against the research creep's n-max 3 shallow cell | 15.79 tok/s at n-max 3, 12.92 (74.5% accept) at n-max 4, 11.13 (62.8% accept) at n-max 6; n-max 3 stays the best drafter setting |
| real text, llama-benchy | 2026-09-12 | f16 KV, no drafter, `-c 106496` | 14.3 tok/s at 4K, 9.6 tok/s at 98K; the drafter loses at every depth on real text (12.2/8.8 at n-max 1, 8.1/7.4 at n-max 3, 35 to 69 percent acceptance) |

The full curve is on [the benchmarks page](../setups/kamaji/benchmarks/qwen3.8-27b.md).

## Server presets

<!-- gen:binary-presets:start -->
### `qwen3.8-27b` {#preset-qwen3-8-27b}

M1 Max 32 GB, a section of `hardware/kamaji/models.ini` (llama-server).

```ini
[qwen3.8-27b]
hf = AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 106496
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:binary-presets:end -->

## Log

- 2026-09-07 — Picked as one of three 3-bit candidates in a research
  run on the M1 Max 32 GB, with the unsloth and ISTA-DASLab 3-bit files;
  the owner approved the three downloads the same evening.
  `hardware/kamaji/research/qwen38-configs.md`.
- 2026-09-07 to 2026-09-08 — Research run: creep with the MTP drafter
  at n-max 3, `-c 106496`. The sweep ran the whole depth list to 98338
  tokens with no stop condition, so 98338 is a list end, not a
  measured ceiling. Both smokes (EvalPlus 4/4, Mendel 9 calls/1
  commit/no loop) passed level with the 4-bit control.
  `hardware/kamaji/research/run3/`.
- 2026-09-08 — This file took the seat the unsloth UD-Q3_K_XL build
  left when the owner dropped that build mid-run.
  `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-08 to 2026-09-09 — Full EvalPlus gate at effort medium,
  budget 8886: 0.988/0.927, no empty of 164, the project's best base
  score of any local build, in 3h11 of active time.
  `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-09 — The owner banned effort medium on Qwen3.8-27B. Every
  medium row keeps its numbers as a record, with no re-run.
  `benchmarks/PLANNING.md`.
- 2026-09-09 — The owner asked for an n-max sweep of this build's own
  before its Mendel row started, rather than carrying over the control
  row's sweep. One 1024-token completion per cell at `-c 4096` and
  temperature 0: n-max 3 reads 15.79 tok/s against 12.92 at n-max 4
  and 11.13 at n-max 6, so n-max 3 stays the served value.
  `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-09 — Mendel blind at effort medium, `-c 106496`, window
  98304, MTP n-max 3: `end_reason repetition_loop`, pi's own detector,
  five identical `bash` searches of an empty directory. Invalid per
  the run's own rule, no retry. A partial score (74 raw, 37.5 capped,
  3 of 8) was computed on `mendel-benchmark`'s `benchmark` branch by a
  general-purpose scorer working from the project's looser partial-run
  rule. The run's own tables do not count that score; the site row
  carries it.
  `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-12 — Real-text speed with llama-benchy: no drafter reads
  14.3 tok/s at 4K and 9.6 at 98K, and the MTP drafter loses at every
  depth (12.2 and 8.8 at n-max 1, 8.1 and 7.4 at n-max 3), so the
  served command carries no drafter.
  `hardware/kamaji/benchmarks/bench16/`.
