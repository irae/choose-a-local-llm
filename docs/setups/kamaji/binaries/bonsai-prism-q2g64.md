# Ternary-Bonsai-27B Q2_g64 (prism-ml, prism fork) on M1 Max 32 GB

File: [`prism-ml/Ternary-Bonsai-27B-gguf`](https://huggingface.co/prism-ml/Ternary-Bonsai-27B-gguf),
`Ternary-Bonsai-27B-Q2_g64.gguf`, a ternary (2-bit) GGUF at group size 64.
Server: the PrismML llama.cpp fork (`prism-llama`, side-by-side install,
binary revision `abbae72`), q4_0 KV with a per-model bias file for the
scored config, f16 KV for the no-drafter arm. Every run of this file on
this machine is on this page, retired and superseded rows included; a
run a harness or serving defect voided is not.

- **Why it is here.** The repo also ships a plain `Q2_0` file and a
  `PQ2_0` file. The plain layout is blocked on the machine's brew
  llama.cpp (needs a build newer than 10621), and the `-hf` tag for it
  wrongly resolves to the `PQ2_0` file. The `Q2_g64` file loads only on
  PrismML's own fork, so the fork is the only path to a native GGUF
  reading of this model here.
- **What it settled.** At q4_0 KV the fork floors near 30 to 33
  thousand used tokens, with or without the DSpark drafter and with or
  without the rotation and bias flags. At f16 KV, no drafter, the same
  fork holds above the 8 tok/s floor all the way to the `-c` boundary,
  131072 tokens, at the cost of roughly double the memory. The DSpark
  drafter raises shallow decode but always costs floor depth, so the
  served config drops it.
- **Where it stands.** The scored q4_0-KV-plus-bias config carries
  EvalPlus 0.927/0.890. Its blind Mendel row (60.5/100, one of eight
  libraries) still needs the from-scratch retry the owner asked for.
  Its guided Mendel row stands at 31.5/100 (three of eight libraries)
  after the owner hand-capped a 469-minute run at 300 minutes. The f16
  KV arm has no EvalPlus score yet, and the reasoning-budget test
  queued for this file has not run.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" page="/setups/kamaji/binaries/bonsai-prism-q2g64" top /> | 33k | speed | <TokCell shallow="14.7" deep="7.8" top-deep /> | **9.6 GB** | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 9h55 · Mendel 5h00">14h55</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" page="/setups/kamaji/binaries/bonsai-prism-q2g64" top /> | **2x48k** | speed | <TokCell shallow="14.9" deep="7.8" stale top-shallow top-deep /> | **10.9 GB** | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h55 · Mendel —">9h55†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" page="/setups/kamaji/binaries/bonsai-prism-q2g64" /> | **131k** | mem | <TokCell shallow="15.0" deep="9.7" stale top-shallow top-deep /> | 18.6 GB | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" top /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" page="/setups/kamaji/binaries/bonsai-prism-q2g64" />](../benchmarks/bonsai-27b.md) | 10240 | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | 4 budget | <TokCell shallow="14.7" deep="7.8" /> | 9h55 |
<!-- gen:binary-evalplus:end -->

Every empty on the scored q4_0-KV-plus-bias config is proven as the
output budget: a 2026-09-16 re-run of its four empty problems
(HumanEval/47, 84, 97, 129) hit the 10240 cap again on every one, none
recovered.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" page="/setups/kamaji/binaries/bonsai-prism-q2g64" /> | blind-v1.1 | 64k | **12.5** (raw 60.5) | 1/8/done | 43.1 | 1,718k | 51k | 0 | 76 | 2 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" page="/setups/kamaji/binaries/bonsai-prism-q2g64" /> | guided-v3.0 | 64k | **31.5** | 3/8/partial | 300.0 | 0k | 63k | 10 | 343 | 3 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" page="/setups/kamaji/binaries/bonsai-prism-q2g64" /> | guided-v3.0 | 128k | **12.5** | 1/8/partial | 194.7 | 21,049k | 127k | 1 | 376 | 2 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The blind row (60.5, one of eight libraries) ended on a self-inflicted
scope error, not a from-scratch retry; the owner's retry-with-penalty
instruction for it is still open. The f16 KV guided row (12.5, one of
eight libraries) hit a critical defect: a dependency removal commit
dropped a package still required elsewhere, and `eslint` failed at the
tip though it passed at the base.

## Speed and context

<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| baseline and DSpark sweep | 2026-08-28 | q8_0 KV, `-c` alloc 32K to 128K, DSpark drafter n-max 1/2/4 | plain q4 KV floors near 30K at 9.8 GB RSS; DSpark n2 raises shallow decode (19.1 tok/s, 69% accept) but drops the floor to about 20K; n1 is the least bad drafter arm (floor ~23K) |
| two-slot concurrency | 2026-08-28 | `--parallel 2 -c 98304`, q4_0 KV, no drafter | both slots decoding at 9.8 and 9.9 tok/s (aggregate 19.7, +35% from batching), 10.0 GB RSS |
| depth sweep, rotation + bias flags | 2026-08-30 | q4_0 KV, `--kv-mean-center` bias, single slot and 2×48K | single slot crosses 8 tok/s at 32.8K (9.6 GB RSS); the 2-slot slot-0 sweep crosses at the same 32.8K (10.9 GB RSS) — the bias and rotation flags do not move the floor |
| creep, no drafter | 2026-09-08 | f16 KV, `-c 131072`, wired limit 25000 | 14.95 tok/s at 4K, 9.67 tok/s at 131098, the `-c` boundary itself; wired flat at 18.2-18.6 GB, zero swap growth, no floor found |

The full sweep tables are on [the benchmarks page](../benchmarks/bonsai-27b.md).

## Log

- 2026-08-28 — The fork installed side by side with brew llama.cpp
  (owner-approved exception) to load the `Q2_g64` file. Baseline at
  q8_0 KV: 16.6 tok/s. DSpark drafter converted locally from the bf16
  file and swept at n-max 1/2/4: n2 best shallow, every arm costs
  floor depth. Depth sweep across KV types and alloc sizes: q4 KV
  beats q8 on both floor and memory, allocation size only taxes decode
  at the full 262K window. Two-slot concurrency measured at q4_0 KV.
  `hardware/kamaji/benchmarks/bench3/`.
- 2026-08-29 to 2026-08-30 — EvalPlus quality gate at the scored
  config (q4_0 KV, PrismML's `--kv-mean-center` bias file, thinking
  on, budget 10240): 0.927/0.890, 4 of 164 completions empty at the
  full budget, resumed cleanly from a 72/164 partial left by an
  earlier attempt. `benchmarks/mem-watch.sh` ran the whole time, no
  crash signatures. `hardware/kamaji/benchmarks/bench4/`.
- 2026-08-30 — Depth sweeps re-run with the scored config's rotation
  and `--kv-mean-center` bias flags, single-slot and the 2×48K
  2-slot's slot 0: both cross the 8 tok/s floor at 32.8K, matching the
  plain-q4 proxy closely — the bias and rotation flags do not move the
  floor. `hardware/kamaji/benchmarks/bench5/`.
- 2026-09-02 to 2026-09-03 — Mendel blind at thinking high: 60.5/100,
  one of eight libraries. The model typoed the repo path, got repeated
  404s on the issue fetch, then self-scoped the whole task to one
  library found via `git log`. The owner asked for a from-scratch
  retry and set the rule that a retry after a model failure costs 10
  points for each earlier valid attempt. Mendel guided at thinking
  high was aborted by the owner mid-run, about 94 minutes in, for
  time, not a model failure; its worktree and branch were discarded
  and no row was scored. `hardware/kamaji/benchmarks/bench7/`.
- 2026-09-06 to 2026-09-07 — Mendel guided at thinking high, run from
  scratch. The KV bias file was missing (its corpus was never
  recorded and the original file was lost with `/tmp` on a reboot) and
  was regenerated with the vendor's `make_kv_bias.sh` and its built-in
  corpus. The run went 469 minutes with no natural end; a Mendel
  harness bug meant its 300-minute wall-clock cap was never enforced.
  The owner had the data hand-capped at 300 minutes: score 31.5/100,
  three of eight libraries. `hardware/kamaji/benchmarks/bench11/`.
- 2026-09-08 — Fork at f16 KV, no drafter, wired limit 25000: creep to
  the `-c 131072` boundary at 9.67 tok/s, no floor found, wired flat,
  zero swap growth. Mendel guided at thinking high, under a fresh
  model id (`bonsai-prism-f16`) to avoid a branch-name collision with
  the q4_0 row: 12.5/100 capped from 36 raw, one of eight libraries, a
  critical defect (a dependency removal commit dropped a package a
  test helper still required, and linting failed at the tip though it
  passed at the base). EvalPlus at f16 KV is still pending.
  `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-15 to 2026-09-16 — Re-run of the four empty EvalPlus problems
  on the scored q4_0-KV-plus-bias config: HumanEval/47, 84, 97 and 129
  all hit the 10240 cap again; cause `budget` on every one, none
  recovered. `hardware/kamaji/benchmarks/bench20/`.
- Pending — the fork carries `--reasoning-budget` and
  `--reasoning-budget-message` (confirmed 2026-09-16). Four blocks are
  queued to test it on this file — calibration, a budgeted EvalPlus
  run, a forced-failure re-run, and a budgeted Mendel guided run — but
  none has run yet. `hardware/kamaji/benchmarks/bench22/`.
