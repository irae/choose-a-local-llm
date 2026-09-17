# Qwen3.8-27B AD-IQ3_S (AtomicChat) on M1 Max 32 GB

File: [`AtomicChat/Qwen3.8-27B-GGUF`](https://huggingface.co/AtomicChat/Qwen3.8-27B-GGUF),
`AD-IQ3_S`, revision `ca10ebc`, about 13.84 GB, an "Atomic Dynamic"
3-bit layout with extra bits on the attention gate and the state
output path. Server: llama-server, f16 KV on this machine. Every run
of this file on this machine is on this page, retired and superseded
rows included; a run a harness or serving defect voided is not.

- **Why it is here.** One of three 3-bit candidates picked for the
  12 GB budget on 2026-09-07, chosen because it drifts 18 percent less
  from BF16 than the unsloth candidate at almost the same size, by the
  publisher's own KLD measurement (0.0325 against 0.0397 mean KLD).
- **What it settled.** The MTP drafter loses at every depth on real
  text, so it serves without one. It holds the project's best single-
  turn base score, 0.988, at effort medium. Medium banned outright for
  this model on 2026-09-09; every row on this page is a record.
- **Where it stands.** Blind 37.5 of 100 (capped from 74 raw) at
  effort medium on a 98K window, ended on a repetition loop after
  three of eight libraries. No xhigh or low row exists.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" page="/setups/kamaji/binaries/qwen38-atomicchat-ad-iq3s" top /> | **104k** | mem | <TokCell shallow="14.3" deep="9.6" top-shallow top-deep /> | **24.1 GB** | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 3h11 · Mendel 1h00">4h10</span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/setups/kamaji/binaries/qwen38-atomicchat-ad-iq3s" />](../benchmarks/qwen3.8-27b.md) | 8886 | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | none | <TokCell shallow="14.3" deep="9.6" /> | 3h11 |
<!-- gen:binary-evalplus:end -->

No empty completions on this file's only EvalPlus run (0/164 at
budget 8886).

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/setups/kamaji/binaries/qwen38-atomicchat-ad-iq3s" /> | blind-v1.1 | 96k | **37.5** | 3/8/partial | 59.8 | 7,025k | 70k | 0 | 189 | 7 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The row ended on a repetition loop: five identical `bash` searches of
a directory that held nothing the model wanted. Pi's own live
detector caught it; `loop-check.py`'s 60-line sliding window missed
it, a tool gap filed for the coordinator and not fixed mid-run.

## Speed and context

<ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| creep | 2026-09-07 to 2026-09-08 | MTP n-max 3, `-c 106496` | 98338 tokens, no stop condition hit — a list end, not a measured ceiling |
| n-max sweep, one real completion each | 2026-09-12 | n-max 3, 4, 6 at depth 4096 | 15.79 tok/s at n-max 3, 12.92 (74.5% accept) at n-max 4, 11.13 (62.8% accept) at n-max 6; n-max 3 stays the best drafter setting |
| real text, llama-benchy | 2026-09-12 | no drafter | 14.3 tok/s at 4K, 9.6 tok/s at 98K; the drafter loses at every depth on real text (12.2/8.8 at n-max 1, 8.1/7.4 at n-max 3, 35 to 69 percent acceptance) |

The full curve is on [the benchmarks page](../benchmarks/qwen3.8-27b.md).

## Log

- 2026-09-07 — Picked as one of three 3-bit candidates in a research
  run on this machine, with the unsloth and ISTA-DASLab 3-bit files;
  the owner approved the three downloads the same evening.
  `hardware/kamaji/research/qwen38-configs.md`.
- 2026-09-07 to 2026-09-08 — Research run: creep with the MTP drafter
  at n-max 3, `-c 106496`. The sweep ran the whole depth list to 98338
  tokens with no stop condition, so 98338 is a list end, not a
  measured ceiling. Both smokes (EvalPlus 4/4, Mendel 9 calls/1
  commit/no loop) passed level with the 4-bit control.
  `hardware/kamaji/research/run3/`.
- 2026-09-08 — Full EvalPlus gate at effort medium: 0.988/0.927, no
  empty of 164, the project's best base score of any local build, in
  3h11. `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-08 to 2026-09-09 — A strip item meant for the served 4-bit
  row was mistakenly dropped into this build's slot mid-run; the
  coordinator stopped it at 39 of 164 problems and replaced it with
  the real `qwen38-atomicchat-evalplus` block. The partial data stays
  committed as an abandoned partial, not deleted, and carries no
  score on this page. `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-09 — Medium banned on this model. Every medium row on this
  page keeps its numbers as a record.
- 2026-09-09 — Owner asked for an n-max sweep of this build's own
  before its Mendel row starts, rather than carrying over the control
  row's sweep. `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-09 — Mendel blind at effort medium, `-c 106496`, window
  98304, MTP n-max 3: `end_reason repetition_loop`, pi's own detector,
  five identical `bash` searches of an empty directory. Invalid per
  the run's own rule, no retry. A partial score (74 raw, 37.5 capped,
  3 of 8) was computed on `mendel-benchmark`'s `benchmark` branch by a
  general-purpose scorer working from the project's looser partial-run
  rule; this run's own tables carry that number as the row's score.
  `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-12 — n-max sweep of this build's own: n-max 3 confirmed as
  the fastest drafter setting, and real-text speed with llama-benchy
  showed the MTP drafter losing at every depth, so the served command
  carries no drafter. `hardware/kamaji/benchmarks/bench16/`.
