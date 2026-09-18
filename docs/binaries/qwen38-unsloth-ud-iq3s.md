# Qwen3.8-27B UD-IQ3_S (unsloth)

File: [`unsloth/Qwen3.8-27B-GGUF`](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF),
`Qwen3.8-27B-UD-IQ3_S.gguf`, revision `4ca7207`, about 12.04 GB. The
M1 Max runs it on llama-server with f16 KV. The RTX 5060 Ti runs it on
llama-server on CUDA with q8_0 KV. Every run of this file on every
machine is on this page, retired and superseded rows included; a run
a harness or serving defect voided is not.

- **Why it is here.** unsloth's 3-bit repack of Qwen3.8-27B, read
  beside the ISTA-DASLab 3-bit build on both machines as each card's
  second 3-bit candidate, and run on the M1 Max and the RTX 5060 Ti so
  the two Qwen3.8 3-bit builds compare across machines.
- **What it settled.** The M1 Max build matches the ISTA build's
  EvalPlus base score with a higher plus score at a smaller output
  budget, and scores 90.5 of 100 on the Mendel blind test, against the
  ISTA build's 80.5; the blind row carries an anomaly: the model
  merged `master` into its own branch mid-run and imported
  infrastructure the blind base hides, so the coordinator kept the
  score but marked the row not base-comparable. The RTX 5060 Ti's
  q8_0 arm serves a wider window than its f16 arm (65536 against
  53248) at a slightly slower deep-cell speed, leads the ISTA build on
  EvalPlus at xhigh (0.957/0.921 against 0.945/0.909), but stops the
  agent task at 7 of 8 where the ISTA build finishes 8 of 8. Across
  machines, EvalPlus reads 0.945/0.927 on the M1 Max against
  0.957/0.921 on the RTX 5060 Ti.
- **Where it stands.** Blind 90.5 of 100 on the M1 Max, 8 of 8, at
  effort xhigh on a 147456 window, measured 2026-09-15; no blind row
  on the RTX 5060 Ti, since only the ISTA build qualified for that
  card's blind slot. Guided scores 62.5 on the M1 Max (147456 window,
  a valid partial at the 300-minute wall cap, 5 of 8 libraries)
  against 79 on the RTX 5060 Ti (61440 window, 7 of 8, measured
  2026-09-14). The M1 Max's eight EvalPlus empties
  are proven as the output budget; a re-run at the same budget did not
  clear them. The RTX 5060 Ti's three EvalPlus empties of 164 at
  budget 19000 are unproven, since the run branch predates the finish
  log.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-unsloth-ud-iq3s" top /> | **147k** | <TokCell shallow="13.60" deep="7.97" cap="speed" top-shallow top-deep /> | **25.5 GB** | <ScoreCell value="0.945/0.927" sub="100% completion" top /> | <ScoreCell value="90.5" pill="mendel-blind" top /> | <span title="EvalPlus 13h36 · Mendel 3h05"><b>16h41</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-unsloth-ud-iq3s" top /> | **65k** | <TokCell shallow="29.36" deep="20.92" cap="mem" top-shallow top-deep /> | **14.2 GB** | <ScoreCell value="0.957/0.921" sub="98% completion" top /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus 4h50 · Mendel 4h46"><b>9h36</b></span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-unsloth-ud-iq3s" />](../setups/arrietty/benchmarks/qwen3.8-27b.md) | 19000 | <ScoreCell value="0.957/0.921" sub="98% completion" top /> | † unproven | <TokCell shallow="29.36" deep="20.92" /> | 4h50 |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-unsloth-ud-iq3s" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 20000 | <ScoreCell value="0.945/0.927" sub="95% completion" top /> | 8 budget | <TokCell shallow="13.60" deep="7.97" /> | 13h36 |
<!-- gen:binary-evalplus:end -->

On the M1 Max, every empty on this file is the output budget
(2026-09-16): 42 of the 65 problems re-run across eight Mac rows hit
`finish_reason: length` at the same budget, this file's eight
included; none stopped with no answer. The re-run at the same
20000-token budget did not clear any of them. On the RTX 5060 Ti, the
empty count is `† unproven`: the run branch predates the finish log,
so the cause of the 3 empty answers of 164 at budget 19000 is not
recorded.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-unsloth-ud-iq3s" /> | blind-v1.1 | 144k | **90.5** | 8/8/done | 185.4 | 15,060k | 143k | 1 | 240 | 19 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-unsloth-ud-iq3s" /> | guided-v3.0 | 64k | **79** | 7/8/partial | 285.9 | 11,327k | 58k | 35 | 332 | 7 |  |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-unsloth-ud-iq3s" /> | guided-v3.0 | 144k | **62.5** | 5/8/partial | 300.0 | 16,902k | 143k | 1 | 243 | 5 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The M1 Max's blind row's score stands as published; the coordinator
marked it not base-comparable because the model merged `master` into
its own branch mid-run and imported infrastructure the blind base
hides. The M1 Max's guided row ended at the 300-minute wall-clock cap
with 5 of 8 libraries done; it counts as a valid partial, not a
failure. The RTX 5060 Ti's guided row ended partial, 7 of 8, after two
host-memory kills on its first two attempts and a mid-run GPU
watchdog hang recovered inside the same session on the third; no
blind row ran on this build.

## Speed and context

<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" hide="drafter,effort,kv" />

| machine | measurement | date | config | result |
|---|---|---|---|---|
| M1 Max 32 GB | ladder | 2026-09-14 | f16 KV, no drafter, wired limit 25000 | `-c 188416` is the largest value that loads; `-c 196608` hits a Metal out-of-memory at load |
| M1 Max 32 GB | creep | 2026-09-14 | f16 KV, no drafter, `-c 188416` | clean to 147478 tokens at 8.17 tok/s, stops on the 8 tok/s floor at depth 163858, no swap growth |
| M1 Max 32 GB | real text, llama-benchy | 2026-09-14 | f16 KV, no drafter | 13.60 tok/s at 4K, 8.19 at 138K, 7.97 at 147K, just under the creep's floor |
| RTX 5060 Ti 16 GB | ladder and sweep | 2026-09-13 | f16 KV, no drafter, 61440 passed at load then crashed on a real request; stepped down to `-c 53248` | 29.96 tok/s at 4K, 27.21 at 24576, 24.34 at 52224; VRAM flat at 15453 MiB |
| RTX 5060 Ti 16 GB | ladder and sweep | 2026-09-13 | q8_0 KV, no drafter, `-c 65536` passed clean, no retry | 29.36 tok/s at 4K, 25.84 at 24576, 20.92 at 64512; VRAM flat at 14527 MiB, 14.2 GB at the served depth |
| RTX 5060 Ti 16 GB | drafter climb | 2026-09-13 | q8_0 KV, n-max 1, `-c 65536` | 37.16 tok/s at 4K, 34.34 at 24576, 26.28 at 64512 |
| RTX 5060 Ti 16 GB | drafter climb | 2026-09-13 | q8_0 KV, n-max 2, `-c 65536`, fastest of the three arms at the shared depths | 47.05 tok/s at 4K, 37.84 at 24576, 30.82 at 64512 |
| RTX 5060 Ti 16 GB | drafter climb | 2026-09-13 | q8_0 KV, n-max 3, `-c` stepped down to 57344 after a deep-cell OOM | 41.42 tok/s at 4K, 37.61 at 24576, 28.57 at 56320 |

On the M1 Max, wired memory at the two deepest passing rungs
(25344 MB and 25911 MB) reads above the 25000 sysctl limit; the
ladder rule still applied because the sysctl gates the process's
accelerator view, not total wired memory (flagged for the owner,
2026-09-14). The drafter `-c` search never found a fail inside its
four-load budget, so its deepest load, 139264, is not a ceiling; the
real drafter ceiling may reach 188416, and the drafter arms stay
pending. On the RTX 5060 Ti, the
drafter climb is a speed-only block; the guided and EvalPlus rows
both serve the q8_0 arm with no drafter. The full curves are on
[the report page](../setups/arrietty/reports/qwen3.8-27b.md).

## Log

- 2026-09-13 — RTX 5060 Ti: Named in the card's first runbook as the
  unsloth 3-bit control beside the ISTA-DASLab 3-bit build on this
  card. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-13 — RTX 5060 Ti: Speed sweep. The f16 arm passes its load
  check at 61440 but crashes on a real request at warmup, so it steps
  down to `-c 53248` and serves clean, 24.34 tok/s at its deep cell.
  The q8_0 arm passes `-c 65536` clean on the first try, 20.92 tok/s
  at its deep cell, a wider window than f16 at a slightly slower
  speed. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-13 — RTX 5060 Ti: Drafter climb on the q8_0 arm: n-max 2 is
  the fastest arm at the shared depths, n-max 3 needs a smaller `-c`
  and trails it. A speed-only block; the guided task runs with no
  drafter regardless. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-14 — M1 Max: Downloaded and verified as the same file the
  Linux setup serves, sha256 matching. Ladder, creep and real-text
  speed measured at wired limit 25000, no drafter: `-c 188416` clean
  to 147478 tokens at 8.17 tok/s; llama-benchy reads 13.60 tok/s at
  4K, 7.97 at 147K. The drafter `-c` search found no fail inside its
  four-load budget, so its deepest load, 139264, is not a ceiling.
  `hardware/kamaji/benchmarks/bench18/`.
- 2026-09-14 — RTX 5060 Ti: Guided agent task, xhigh, q8_0 KV, no
  drafter, window 61440. Two host-memory kills stopped the first two
  attempts (a false low-memory guard, not real host OOM); a mid-run
  GPU watchdog hang (`CUDA error: the launch timed out and was
  terminated`, Xid 8) recovered inside the third attempt's own
  session, no new attempt needed. Closed at 79, partial 7 of 8, with
  two medium defects: a stale chalk `enableColor` contract and a
  missed rimraf reference. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-15 — M1 Max: EvalPlus at effort xhigh, budget 20000 on
  `-c 32768`: 0.945/0.927, eight empty of 164, in 615.6 minutes of
  active time; the 2026-09-16 re-run adds 200 minutes, for the 13h36
  the table shows. Same base score as the ISTA build on this machine, a
  higher plus score, at a smaller budget; this run saved no finish
  reason for the empties. Mendel blind at effort xhigh: 90.5/100,
  complete 8/8, but the model merged `master` into its own branch
  mid-run and imported infrastructure the blind base hides, so the
  coordinator kept the score and marked the row not base-comparable.
  Mendel guided at effort xhigh: 62.5 displayed of 76 raw, a valid
  partial at the 300-minute wall cap, 5 of 8 libraries. The EvalPlus
  watcher exited 42 twice during the guided block while the server
  still answered `/health`, so the run continued.
  `hardware/kamaji/benchmarks/bench18/`.
- 2026-09-15 — RTX 5060 Ti: Owner decision: EvalPlus on this build
  serves without a drafter, since a drafter never changes an answer at
  temperature 0. `hardware/arrietty/benchmarks/bench19/`.
- 2026-09-15 to 2026-09-16 — M1 Max: Re-run of the eight empty
  EvalPlus problems at the same budget: all eight hit
  `finish_reason: length` again at budget 20000, cause `budget`; none
  recovered, 200 minutes added to the wall.
  `hardware/kamaji/benchmarks/bench20/` (`qwen38-unsloth-xhigh-rerun`).
- 2026-09-15 to 2026-09-16 — RTX 5060 Ti: EvalPlus at xhigh, q8_0 KV,
  budget 19000: 0.957/0.921, 289.6 minutes. The runner's live count
  read no empty answers; the coordinator re-derived the samples on
  2026-09-16 and found 3 empty of 164.
  `hardware/arrietty/benchmarks/bench19/`.
- Pending — M1 Max: the drafter arms on this file are not measured;
  the thinking-budget test on the Mac does not name this file.
