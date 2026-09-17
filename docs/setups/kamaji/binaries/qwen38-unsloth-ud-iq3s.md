# Qwen3.8-27B UD-IQ3_S (unsloth) on M1 Max 32 GB

File: [`unsloth/Qwen3.8-27B-GGUF`](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF),
`Qwen3.8-27B-UD-IQ3_S.gguf`, revision `4ca7207`, about 12.04 GB, f16 KV.
Server: llama-server, no drafter. Every run of this file on this
machine is on this page, retired and superseded rows included; a run
a harness or serving defect voided is not.

- **Why it is here.** The same file the RTX 5060 Ti setup serves, run
  on the Mac beside the ISTA 3-bit build already on this machine, so
  the two Qwen3.8 3-bit builds compare on one card and across
  machines.
- **What it settled.** The build matches the ISTA build's EvalPlus
  base score with a higher plus score at a smaller output budget, and
  scores higher on the Mendel blind test, 90.5 against 80.5. The blind
  row carries an anomaly: the model merged `master` into its own
  branch mid-run and imported infrastructure the blind base hides, so
  the coordinator kept the score but marked the row not
  base-comparable.
- **Where it stands.** Blind 90.5 of 100, 8 of 8, at effort xhigh on
  a 147k window; guided 62.5 displayed (76 raw), a valid partial at
  the 300-minute wall cap, 5 of 8 libraries. The eight EvalPlus
  empties are proven as the output budget; a re-run at the same
  budget did not clear them.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" top /> | **147k** | speed | <TokCell shallow="13.60" deep="7.97" top-shallow top-deep /> | **25.5 GB** | <ScoreCell value="0.945/0.927" sub="100% completion" top /> | <ScoreCell value="90.5" pill="mendel-blind" top /> | <span title="EvalPlus 13h36 · Mendel 3h05">16h41</span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" />](../benchmarks/qwen3.8-27b.md) | 20000 | <ScoreCell value="0.945/0.927" sub="95% completion" top /> | 8 budget | <TokCell shallow="13.60" deep="7.97" /> | 13h36 |
<!-- gen:binary-evalplus:end -->

Every empty on this file is the output budget (2026-09-16): 42 of the
65 problems re-run across eight Mac rows hit `finish_reason: length`
at the same budget, this file's eight included; none stopped with no
answer. The re-run at the same 20000-token budget did not clear any
of them.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" /> | blind-v1.1 | 144k | **90.5** | 8/8/done | 185.4 | 15,060k | 143k | 1 | 240 | 19 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" /> | guided-v3.0 | 144k | **62.5** | 5/8/partial | 300.0 | 16,902k | 143k | 1 | 243 | 5 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The blind row's score stands as published; the coordinator marked it
not base-comparable because the model merged `master` into its own
branch mid-run and imported infrastructure the blind base hides. The
guided row ended at the 300-minute wall-clock cap with 5 of 8
libraries done; it counts as a valid partial, not a failure.

## Speed and context

<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| ladder | 2026-09-14 | no drafter, wired limit 25000 | `-c 188416` is the largest value that loads; `-c 196608` hits a Metal out-of-memory at load |
| creep | 2026-09-14 | no drafter, `-c 188416` | clean to 147478 tokens at 8.17 tok/s, stops on the 8 tok/s floor at depth 163858, no swap growth |
| real text, llama-benchy | 2026-09-14 | no drafter | 13.60 tok/s at 4K, 8.19 at 138K, 7.97 at 147K, just under the creep's floor |

Wired memory at the two deepest passing rungs (25344 MB and 25911 MB)
reads above the 25000 sysctl limit; the ladder rule still applied
because the sysctl gates the process's accelerator view, not total
wired memory (flagged for the owner, 2026-09-14). The drafter `-c`
search never found a fail inside its four-load budget, so 139264 is
the deepest load tried, not a true ceiling; the drafter arms are
pending.

## Log

- 2026-09-14 — Downloaded and verified as the same file the Linux
  setup serves, sha256 matching. Ladder, creep and real-text speed
  measured at wired limit 25000, no drafter: `-c 188416` clean to
  147478 tokens at 8.17 tok/s; llama-benchy reads 13.60 tok/s at 4K,
  7.97 at 147K. `hardware/kamaji/benchmarks/bench18/`.
- 2026-09-15 — EvalPlus at effort xhigh, budget 20000 on `-c 32768`:
  0.945/0.927, eight empty of 164, in 615.6 minutes of active time.
  Same base score as the ISTA build on this machine, a higher plus
  score, at a smaller budget; this run saved no finish reason for the
  empties. Mendel blind at effort xhigh: 90.5/100, complete 8/8, but
  the model merged `master` into its own branch mid-run and imported
  infrastructure the blind base hides, so the coordinator kept the
  score and marked the row not base-comparable. Mendel guided at
  effort xhigh: 62.5 displayed of 76 raw, a valid partial at the
  300-minute wall cap, 5 of 8 libraries. The EvalPlus watcher exited
  42 twice during the guided block while the server still answered
  `/health`, so the run continued. `hardware/kamaji/benchmarks/bench18/`.
- 2026-09-15 to 2026-09-16 — Re-run of the eight empty EvalPlus
  problems at the same budget: all eight hit `finish_reason: length`
  again at budget 20000, cause `budget`; none recovered, 200 minutes
  added to the wall. `hardware/kamaji/benchmarks/bench20/`
  (`qwen38-unsloth-xhigh-rerun`).
- Pending — the drafter arms on this file are not measured; the
  thinking-budget test on the Mac does not name this file.
