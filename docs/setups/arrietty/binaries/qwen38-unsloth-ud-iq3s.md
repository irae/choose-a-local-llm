# Qwen3.8-27B UD-IQ3_S (unsloth) on RTX 5060 Ti 16 GB

File: [`unsloth/Qwen3.8-27B-GGUF`](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF),
`Qwen3.8-27B-UD-IQ3_S.gguf`, revision `4ca7207`, about 12 GB. Server:
llama-server on CUDA, q8_0 KV. Every run of this file on this machine
is on this page, retired and superseded rows included; a run a harness
or serving defect voided is not.

- **Why it is here.** unsloth's 3-bit repack of Qwen3.8-27B, read
  beside the ISTA-DASLab 3-bit build as this card's second 3-bit
  candidate for the model.
- **What it settled.** The q8_0 arm serves a wider window than the f16
  arm (65536 against 53248) at a slightly slower deep-cell speed, and
  a drafter never wins the guided task, so the served arm carries none.
  This build leads the ISTA build on EvalPlus at xhigh (0.957/0.921
  against 0.945/0.909) but stops the agent task at 7 of 8, where the
  ISTA build finishes 8 of 8.
- **Where it stands.** Guided 79 on a 61440 window, no blind row: only
  the ISTA build qualified for the blind slot on this card.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/setups/arrietty/binaries/qwen38-unsloth-ud-iq3s" top /> | **65k** | mem | <TokCell shallow="29.36" deep="20.92" top-shallow top-deep /> | **14.2 GB** | <ScoreCell value="0.957/0.921" sub="98% completion" top /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus 4h50 · Mendel 4h46">9h36</span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/setups/arrietty/binaries/qwen38-unsloth-ud-iq3s" />](../benchmarks/qwen3.8-27b.md) | 19000 | <ScoreCell value="0.957/0.921" sub="98% completion" top /> | † unproven | <TokCell shallow="29.36" deep="20.92" /> | 4h50 |
<!-- gen:binary-evalplus:end -->

The empty count is `† unproven`: the run branch predates the finish
log, so the cause of the 3 empty answers of 164 at budget 19000 is not
recorded.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/setups/arrietty/binaries/qwen38-unsloth-ud-iq3s" /> | guided-v3.0 | 64k | **79** | 7/8/partial | 285.9 | 11,327k | 58k | 35 | 332 | 7 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The guided row ended partial, 7 of 8, after two host-memory kills on
its first two attempts and a mid-run GPU watchdog hang recovered
inside the same session on the third. No blind row ran on this build.

## Speed and context

<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| ladder and sweep, f16 KV | 2026-09-13 | no drafter, 61440 passed at load then crashed on a real request; stepped down to `-c 53248` | 29.96 tok/s at 4K, 27.21 at 24576, 24.34 at 52224; VRAM flat at 15453 MiB |
| ladder and sweep, q8_0 KV | 2026-09-13 | no drafter, `-c 65536` passed clean, no retry | 29.36 tok/s at 4K, 25.84 at 24576, 20.92 at 64512; VRAM flat at 14527 MiB, 14.2 GB at the served depth |
| drafter climb, q8_0 KV | 2026-09-13 | n-max 1, `-c 65536` | 37.16 tok/s at 4K, 34.34 at 24576, 26.28 at 64512 |
| drafter climb, q8_0 KV | 2026-09-13 | n-max 2, `-c 65536`, fastest of the three arms at the shared depths | 47.05 tok/s at 4K, 37.84 at 24576, 30.82 at 64512 |
| drafter climb, q8_0 KV | 2026-09-13 | n-max 3, `-c` stepped down to 57344 after a deep-cell OOM | 41.42 tok/s at 4K, 37.61 at 24576, 28.57 at 56320 |

The drafter climb is a speed-only block; the guided and EvalPlus rows
both serve the q8_0 arm with no drafter. The full curves are on
[the report page](../reports/qwen3.8-27b.md).

## Log

- 2026-09-13 — Named in the card's first runbook as the unsloth 3-bit control
  beside the ISTA-DASLab 3-bit build on this card.
  `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-13 — Speed sweep. The f16 arm passes its load check at
  61440 but crashes on a real request at warmup, so it steps down to
  `-c 53248` and serves clean, 24.34 tok/s at its deep cell. The q8_0
  arm passes `-c 65536` clean on the first try, 20.92 tok/s at its
  deep cell, a wider window than f16 at a slightly slower speed.
  `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-13 — Drafter climb on the q8_0 arm: n-max 2 is the fastest
  arm at the shared depths, n-max 3 needs a smaller `-c` and trails it.
  A speed-only block; the guided task runs with no drafter regardless.
  `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-14 — Guided agent task, xhigh, q8_0 KV, no drafter, window
  61440. Two host-memory kills stopped the first two attempts (a false
  low-memory guard, not real host OOM); a mid-run GPU watchdog hang
  (`CUDA error: the launch timed out and was terminated`, Xid 8)
  recovered inside the third attempt's own session, no new attempt
  needed. Closed at 79, partial 7 of 8, with two medium defects: a
  stale chalk `enableColor` contract and a missed rimraf reference.
  `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-15 — Owner decision: EvalPlus on this build serves without a
  drafter, since a drafter never changes an answer at temperature 0.
  `hardware/arrietty/benchmarks/bench19/`.
- 2026-09-15 to 2026-09-16 — EvalPlus at xhigh, q8_0 KV, budget 19000:
  0.957/0.921, 289.6 minutes. The runner's live count read no empty
  answers; the coordinator re-derived the samples on 2026-09-16 and
  found 3 empty of 164. `hardware/arrietty/benchmarks/bench19/`.
