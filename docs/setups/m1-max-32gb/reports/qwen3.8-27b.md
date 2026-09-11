# Qwen3.8-27B on M1 Max 32 GB

Backends: llama-server, mlx-lm · [Qwen3.8-27B MLX 4-bit on Hugging Face](https://huggingface.co/mlx-community/Qwen3.8-27B-4bit)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>0.988 / 0.945</b><span>EvalPlus, effort medium — best base is the AtomicChat 3-bit GGUF (100%), best plus is the ISTA 3-bit GGUF (99%); the ISTA build scores 0.976 / 0.933 / 99% at effort low and 0.945 / 0.921 / 97% at xhigh</span></div>
  <div class="kpi"><b>93 / 100</b><span>Mendel blind, effort xhigh, the model's own default: 4-bit GGUF f16 KV with its drafter, 65K window, complete, no critical defect; the ISTA 3-bit build at xhigh scored 80.5 on a 147K window, complete</span></div>
  <div class="kpi"><b>147K</b><span>deepest clean GGUF f16 KV depth, the 3-bit ISTA build without its drafter, 8.3 tok/s there</span></div>
  <div class="kpi"><b>28K</b><span>MLX memory ceiling</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 (llama build 10621, mlx-lm 0.31.3); the three GGUF builds measured at f16 KV and wired limit 25000 on 2026-09-08; the ISTA build without its drafter measured, run on Mendel at effort xhigh and low, and sampled 2026-09-09 to 2026-09-10; the 4-bit build read on real text at the server's sampling and run on Mendel at effort xhigh on 2026-09-11.

## Highlights

- **At its own default level the model finishes the agent task at
  93.** The 4-bit GGUF with its drafter at f16 KV on a 65K window
  scores 93 of 100 on the Mendel blind task at effort xhigh: all eight
  libraries, no critical defect, three traps handled, 213 minutes,
  three compactions. The ISTA 3-bit GGUF without its drafter on a 147K
  window scores 80.5 at the same level, complete, with one critical
  trap; at effort low it scores 66, partial. One run of this task
  carries about ten points of noise, so the two builds are not yet
  ordered. Every earlier row ran at effort medium, which this model is
  no longer tested at.
- **Dropping the drafter buys the 3-bit build depth and speed.**
  Without it the ISTA build serves `-c 163840` and holds 8.3 tok/s at
  147K of clean context; with it, 9.7 at 115K. The drafter is slower at
  every depth tried, 12.4 against 14.4 tok/s at depth 256 and 7.9
  against 9.5 at 98K, because acceptance falls faster than the draft
  grows.
- **The best quality score of any config measured here.** EvalPlus
  0.988 base on the AtomicChat 3-bit build and 0.945 plus on the ISTA
  3-bit build, both at effort medium. On the ISTA build the level
  moves the single-turn score the other way from the agent score:
  low reads 0.976 / 0.933 / 99%, level with medium on base, and xhigh
  reads 0.945 / 0.921 / 97% with five completions that never converged
  inside a 30000-token cap.
- Weak point: the slowest model on this hardware. On real text at the
  server's sampling the 4-bit GGUF with its drafter reads 11.8 tok/s
  shallow and 8.6 at 65.5K, and the 3-bit without one 14 shallow and
  8.3 at 147K; prompt processing is poor (~123 tok/s). MLX holds 14 to
  17 tok/s across its window and OOMs between 28K and 30K.

## All configs — this model

<!-- gen:model-table:start -->
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus | Mendel |
|--:|---|--:|:--:|--:|--:|--:|--:|
| 1 | Qwen3.8-27B, GGUF Q4_K_M (bartowski), MTP, f16 KV, effort medium | 72k | mem | 11.8 → 8.6 | 25.0 GB | 0.982/0.939/100% | 87 |
| 2 | Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), no drafter, f16 KV, effort xhigh | 147k | speed | 14.1 → 8.3 | 24.4 GB | 0.945/0.921/97% | 80.5 |
| 3 | Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), MTP, f16 KV, effort medium | 128k | mem | 15.1† → 9.7† | 24.2 GB | 0.976/0.945/99% | 76.5 |
| 4 | Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), no drafter, f16 KV, effort low | 147k | speed | 14.1 → 8.3 | 24.4 GB | 0.976/0.933/99% | 66 (partial) |
| 5 | Qwen3.8-27B, GGUF AD-IQ3_S (AtomicChat), MTP, f16 KV, effort medium | 104k | untested | 15.8† → 10.3† | 24.1 GB | 0.988/0.927/100% | 37.5 (partial) |
| 6 | Qwen3.8-27B, MLX 4-bit, unquantized KV, effort low | 28k | mem | 17 → 15.3 | 22.0 GB | 0.976/0.927/100% | 12.5 (partial) |
| 7 | Qwen3.8-27B, MLX 4-bit, unquantized KV, effort medium | 28k | mem | 17 → 15.3 | 22.0 GB | 0.982/0.939/100% | not run |
| 8 | Qwen3.8-27B, GGUF Q4_K_M (bartowski), MTP, f16 KV, effort xhigh | 72k | mem | 11.8 → 8.6 | 25.0 GB | pending | 93 |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
**#1 — Qwen3.8-27B, GGUF Q4_K_M (bartowski), MTP, f16 KV, effort medium.** pi id `qwen3.8-27b`. Re-measured 2026-09-08 at wired limit 25000: `-c 73728` serves, `-c 81920` OOMs at load, and decode and draft acceptance stay flat across the whole served range, so the boundary is memory alone. Speeds read 2026-09-11 with llama-benchy on real code text at the server's own sampling: 11.8 tok/s at 4K and 8.6 at 65.5K, draft acceptance 37 to 63 percent, wired 25.0 GB, zero swap growth. The older `-c 49152` was the ceiling at wired 24000. The EvalPlus score is still the MLX effort-medium run, carried by the shared-score rule; this build has no full EvalPlus of its own, so it cannot be read against the two 3-bit builds below, which do. Mendel blind at effort medium: 87/100 at reserve 16384 and window 49152, and 76/100 on the 2026-09-08 re-run at reserve 8192 and window 65536. The two are different configurations, not a repeat: the second failed trap A, which the first passed.

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

**#2 — Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), no drafter, f16 KV, effort xhigh.** pi id `qwen3.8-27b-ista`. The same build with the drafter off, measured 2026-09-09 at wired limit 25000. Without the drafter `-c 163840` serves, and the creep runs clean to 147478 tokens at 8.30 tok/s before the speed floor; swap never grew. The drafter is a loss on this build at every depth tried: at depth 256, no drafter reads 14.4 tok/s against 12.4 at n-max 3, and at depth 98338 it reads 9.5 against 7.9, so the no-drafter server is both faster and 33K deeper. Mendel blind at effort xhigh, the model's own default: 80.5/100, complete 8/8, one critical trap, 109 minutes, peak context 117,940 of a 147,456 window, no compaction. Sampling recorded for the first time on this machine: temperature 1.0, top_p 0.95, the values llama-server reads from the model file. EvalPlus at effort xhigh, scored 2026-09-10 at budget 30000 on the same build served at `-c 32768`: 0.945/0.921, five empty, every one a completion that hit the 30000-token cap, in about 9h43 of active wall time; below the medium and low rows on both metrics. More thinking does not help this model on short single-turn problems.

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b-ista --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 163840 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

**#3 — Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), MTP, f16 KV, effort medium.** A 3-bit build of the same model, revision `d562806`, with its drafter on. Measured 2026-09-08 at wired limit 25000. Clean depth 114718 at 9.7 tok/s; `-c 131072` serves. `n-max 3` is the best drafter setting on this build, confirmed by a sweep: 4 and 6 were both slower. EvalPlus 0.976/0.945, one empty at budget 8192, its own score and not a carried one. Mendel blind at effort medium: 76.5/100, complete 8/8, window 114688. It failed trap A in the same shape as the 4-bit row's own re-run. The drafter costs this build speed at every depth, so the two no-drafter rows below are the served pick; this row stays as the drafter measurement and the medium score.

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 131072 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

**#4 — Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), no drafter, f16 KV, effort low.** Curve shared with the effort-xhigh row: same server, same weights; the harness sets the level per request. Mendel blind at effort low: 66/100, partial, 7 of 8 libraries, two traps hit, 163 minutes, peak context 130,154 of the same window. The run ended on the harness's 25-minute turn cap during a full test suite, not on the rubric. Low scored lower than xhigh and spent more context and more wall time doing it. EvalPlus at effort low, scored 2026-09-10 at budget 8192 on the same build served at `-c 32768`: 0.976/0.933, one empty, in 2h23; level with the medium row on base and one problem lower on plus. The calibration converged on all 10 problems with a 3634-token maximum.

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b-ista --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 163840 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

**#5 — Qwen3.8-27B, GGUF AD-IQ3_S (AtomicChat), MTP, f16 KV, effort medium.** A second 3-bit build of the same model, revision `ca10ebc`. Measured 2026-09-08 at wired limit 25000. Its sweep reached 98338 at 10.3 tok/s and never hit a stop condition, so that depth is where the sweep ended and not a ceiling this machine refused to pass. `n-max 3` is this build's own value, confirmed by a sweep: 4 and 6 were both slower. EvalPlus 0.988/0.927, no empty completions, the best base score of any local build here and its own score, not a carried one. Mendel blind at effort medium: 37.5/100 capped from 74 raw, partial at three of eight libraries. It ended on a repetition loop, five identical searches of a directory that held nothing it wanted.

```bash
llama-server -hf AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 106496 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

**#6 — Qwen3.8-27B, MLX 4-bit, unquantized KV, effort low.** Curve shared with the effort-medium row: same server, same weights. The reasoning effort changes the output, not the decode speed at a depth.

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
  --chat-template-args '{"reasoning_effort":"low"}' --prompt-cache-size 2 --port 8081
```

**#7 — Qwen3.8-27B, MLX 4-bit, unquantized KV, effort medium.** Set the harness compaction threshold at ~26K. No Mendel run is planned: the agent task needs about 46K of context and this server holds 26K, so every attempt on this build was partial or invalid, and medium is no longer run on this model.

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
  --reasoning-effort medium --port 8081
```

**#8 — Qwen3.8-27B, GGUF Q4_K_M (bartowski), MTP, f16 KV, effort xhigh.** Curve shared with the effort-medium row: same server, same weights; the harness sets the level per request. Mendel blind at effort xhigh, the model's own default, measured 2026-09-11: 93/100, complete 8/8, on the 65536 window, no critical defect, one medium, peak context 61572, sampling temperature 1.0 and top_p 0.95 from the server default. The highest Mendel score of any local row. No EvalPlus run exists at this level on a 4-bit build, so the cell is pending.

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

**Effort xhigh beats low on this task, and spends less doing it.** On
the ISTA build without its drafter, at the same 147,456-token window
and the same 8192 reserve, xhigh scored 80.5 with 8 of 8 libraries, 17
commits, 109 minutes and a peak context of 117,940; low scored 66 with
7 of 8, 15 commits, 163 minutes and a peak of 130,154, and ended on the
harness's 25-minute turn cap during a full test suite. More thinking
bought a cleaner migration in less wall time and less of the window.
Both rows hit trap A; low also hit trap C. The xhigh row is the highest
score of any local row at a level this project still runs. Sampling is
recorded on both rows: temperature 1.0 and top_p 0.95, the values
llama-server reads from the model file.

**The drafter is a loss on the ISTA build at every depth.** A five-cell
sweep at depth 256 and again at depth 98,338 put no drafter ahead of
every `n-max` setting on speed, and wired memory moved with `n-max`
(about 1.9 GB at n-max 1, then 150 to 160 MB per extra step) instead of
staying flat. Acceptance falls from 90% at n-max 1 to 64% at n-max 4,
faster than the draft grows, so a longer draft costs more than it wins.
Without the drafter the build serves `-c 163840` and creeps clean to
147,478 tokens at 8.30 tok/s, speed-gated, with zero swap growth; with
it, `-c 131072` and a memory stop past 114,718. The tables are below.

**The window decides whether it finishes engineering tasks.** The
Mendel blind task needs about 46K of context. The 4-bit GGUF at f16
completed it at effort medium: 87 of 100, 10 commits in 129 minutes,
peak context 45,705 of a 49,152 window, no loop; points went on a
lockfile-only install and on commit craft. That row ran with a
16384-token harness reserve; re-run at the 8192 reserve on a 65,536
window, the same build scored 76 and failed trap A. Both rows stand as
different configurations, and neither is a repeat of the other. At
effort xhigh on that same 65,536 window the 4-bit build scored 93,
complete, with three compactions and no critical defect. The
MLX build holds 26K at the same speed, and every run on it was partial
or invalid, two of them Metal OOM crashes when the context grew past
the 26,624-token window. A 26K window cannot hold a task that needs
46K, at any effort level, so no further agent run is planned on the
MLX build; it stays a single-turn option in 22 GB.

**Three bits look free on this hardware, on one comparison.** At
effort medium the ISTA 3-bit build scored 76.5 against the 4-bit
build's 76, failed trap A in the same shape, and reached 114.7K of
clean context against 65.5K. The second 3-bit build, AtomicChat, has
the best EvalPlus base of any local config here and the weakest agent
row: 37.5 capped from 74 raw, partial at three of eight libraries. It
ended on a repetition loop, five identical searches of a directory
that held nothing it wanted. A strong single-turn score did not survive
the agent loop, which this project keeps finding.

**Every row at effort medium is a record, not a target.** Medium was
inherited from a control row and never chosen, and this model is no
longer run at it. The medium rows keep their numbers and earn no
re-run; the rows at xhigh and low are the current measurement of the
model.

**The 4-bit build's drafter does not pay on real text.** The creep
read this row at 20.0 tok/s shallow and 13.7 at 65.5K, on a text that
let the drafter accept every draft. On real code text at the server's
own sampling, draft acceptance sits at 37 to 63 percent and the row
reads 11.8 at 4K and 8.6 at 65.5K, slower shallow than the 3-bit ISTA
build with no drafter. Its no-drafter arm has not been read; the row
keeps the drafter until a measurement says otherwise. Memory, not
speed, still bounds it: 73728 is the largest `-c` this machine loads
at wired 25000, and KV grows only about 0.8 GB per 16K tokens because
the hybrid DeltaNet layers keep no KV.

**The quality score is fair, and it is the project's best.** The output
budget was calibrated to 8192 (its longest observed reasoning was about
2.6K tokens) and the three empty completions left from an earlier,
uncalibrated pass were regenerated. Zero empty completions remain. Full
data: [the benchmarks](../benchmarks/qwen3.8-27b.md).

**The old context maxima are withdrawn.** Every allocation figure for
this model was measured at the retired 27000 wired limit. Those tables
and the q8_0 KV curve are on [the historical page](../historical.md);
do not use them. The f16 ceiling at 49K is a load limit, not a decode
floor. MTP-on-MLX exists only as a CLI with no API, so it is
disqualified for harness use; its raw numbers stay in
[the benchmarks](../benchmarks/qwen3.8-27b.md).

**Open issue: prompt processing.** About 20 tok/s on short prompts and
only 123 to 127 tok/s on 1.5K to 4K prompts, low for this hardware
class. It is independent of MTP, so it looks like a Metal kernel limit
of the hybrid DeltaNet architecture in the current build. Worth
re-testing on future llama.cpp releases.

## Which to pick for a coding task

| need | config | tok/s | context |
|---|---|--:|--:|
| **Agent work at the model's default** | llama-server, no drafter, f16 KV, IQ3_S-mtp ISTA, `-c 163840`, effort xhigh | 14.1 shallow, 8.3 at 147K | 147K clean, harness window 147456 |
| **Shallow speed on llama** | llama-server + MTP n=3, f16 KV, Q4_K_M bartowski, `-c 73728` | 11.8 shallow, 8.6 at 65.5K | 65.5K clean, `-c 73728` the largest that loads |
| **Single-turn work in less memory** | mlx_lm.server, unquantized KV | 14-17 across the window | to ~28K ceiling; too small for the agent task |

## Quality — EvalPlus HumanEval+

| config scored | pass@1 base | pass@1 plus | empty completions | completion |
|---|--:|--:|--:|--:|
| llama-server AD-IQ3_S AtomicChat, f16 KV, effort medium, budget 8886 | **0.988** | 0.927 | 0/164 | 100% |
| mlx_lm.server 4-bit, unquantized KV, effort medium, budget 8192 | 0.982 | 0.939 | 0/164 | 100% |
| llama-server IQ3_S-mtp ISTA, f16 KV, effort medium, budget 8192 | 0.976 | **0.945** | 1/164 | 99% |
| llama-server IQ3_S-mtp ISTA, no drafter, f16 KV, effort low, budget 8192 | 0.976 | 0.933 | 1/164 | 99% |
| llama-server IQ3_S-mtp ISTA, no drafter, f16 KV, effort xhigh, budget 30000 | 0.945 | 0.921 | 5/164 | 97% |

The 4-bit GGUF carries the MLX score under the shared-score rule and
has no full run of its own. The two last rows are the ISTA build at
the levels this model is now run at. **Effort low scores level with
medium on base and one problem lower on plus**, with the same single
empty, in 2h23 against medium's 3h07; the calibration converged on all
ten sample problems, the longest at 3,634 tokens. **Effort xhigh
scores below both**, 0.945 base and 0.921 plus, with five empties,
every one a completion that ran to the 30000-token cap, in about 9h43
of active wall time. More thinking does not help this model on short
single-turn problems and can hurt when it does not converge, on the
same build that finishes the agent task at xhigh in 109 minutes with
the best local score. The two evaluations ran under a fix to
EvalPlus's process limits on macOS, the same fix the first run on this
machine needed, applied to the run's venv before scoring.

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
| test | build | config | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|---|--:|---|--:|--:|--:|--:|--:|--:|---|
| blind-v1.1 | Q4_K_M bartowski | llama-f16-xhigh-ctx.64k | **93** | 8/8/done | 213.3 | 10,077k | 62k | 3 | 272 | 17 |  |
| blind-v1.1 | Q4_K_M bartowski | llama-f16-medium-ctx.48k | **87** | 8/8/done | 129.3 | 5,947k | 46k | 4 | 210 | 10 |  |
| blind-v1.1 | IQ3_S-mtp ISTA | llama-f16-xhigh-ctx.144k | **80.5** | 8/8/done | 109.4 | 10,819k | 118k | 0 | 193 | 17 |  |
| blind-v1.1 | IQ3_S-mtp ISTA | llama-f16-medium-ctx.112k | **76.5** | 8/8/done | 135.2 | 7,890k | 89k | 0 | 195 | 17 |  |
| blind-v1.1 | Q4_K_M bartowski | llama-f16-medium-ctx.64k | **76** | 8/8/done | 97.8 | 5,008k | 60k | 1 | 173 | 12 |  |
| guided-v2.1 | MLX 4-bit | mlx-unquantized-low-ctx.26k † | **75** (raw 84) | 6/8/partial | 153.8 | 1,123k | 23k | 0 | 95 | 6 |  |
| blind-v1.1 | IQ3_S-mtp ISTA | llama-f16-low-ctx.144k | **66** | 7/8/partial | 163.3 | 11,426k | 130k | 0 | 214 | 15 |  |
| blind-v1.0 | MLX 4-bit | mlx-unquantized-default-ctx.26k † | **37.5** (raw 80) | 3/8/partial | 253.5 | 1,777k | 24k | 0 | 135 | 6 |  |
| blind-v1.1 | AD-IQ3_S AtomicChat | llama-f16-medium-ctx.96k | **37.5** | 3/8/partial | 59.8 | 7,025k | 70k | 0 | 189 | 7 |  |
| blind-v1.1 | MLX 4-bit | mlx-unquantized-low-ctx.26k † | **12.5** (raw 67.5) | 1/8/partial | 85.2 | 610k | 24k | 0 | 29 | 1 |  |
| guided-v3.0 | MLX 4-bit | mlx-unquantized-low-ctx.?k † | **0** (raw 34) | 0/8/invalid | 261.3 | 1,254k | 30k | 0 | 48 | 0 |  |

The build cell names the quant and its publisher. The config cell names the server, the KV cache type, the thinking level and the harness window. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.

† a 26624-token window with a 16384-token output budget, our config arithmetic, not the model
<!-- gen:model-mendel:end -->

The full table and the rubric are on [the Mendel page](../benchmarks/mendel.md).

The MLX build gives a 26624-token window. That window stopped the low-effort run.

## Decode speed vs used context

The llama arm, in the shape of
[the comparison table](../comparison.md#decode-speed-vs-used-context-the-8-tok-s-usability-floor).
Slow creeps 2026-09-08 and 2026-09-09, wired limit 25000. Every row is
f16 KV; the drafter rows run the MTP drafter at n-max 3, which each
build's own sweep confirmed as the best drafter setting.

| config | @ 4-8K | @ 16K | @ 33K | @ 49K | @ 98K | capped by |
|---|--:|--:|--:|--:|--:|---|
| **llama, Q4_K_M bartowski, MTP, `-c 73728`** | **11.8** | **16.1** | **16.4** | **15.0** | | mem — swap grew at 73.7K; clean to 65.5K at 8.6 tok/s. The 4K and 65.5K cells were read 2026-09-11 with llama-benchy on real code text at the server's own sampling, acceptance 37 to 63 percent; the others are the creep's readings |
| llama, AD-IQ3_S AtomicChat, MTP, `-c 106496` | 15.8 | 14.8 | 13.7 | 12.7 | 10.3 | untested — swept to 98338 and never hit a stop |
| llama, IQ3_S-mtp ISTA, MTP, `-c 131072` | 15.1 | 14.7 | 13.7 | 12.7 | 10.3 | mem — swap grew at 131.1K; clean to 114718 at 9.7 tok/s |
| **llama, IQ3_S-mtp ISTA, no drafter, `-c 163840`** | **14.1** | **13.3** | **12.4** | **11.5** | **9.7** | speed — 8.30 at 147478, under the floor at 163858; zero swap the whole way |

Wired memory 25.4 GB for the 4-bit build, 24.1 to 24.4 GB for the
3-bit rows. The 4-bit build runs against the wired limit the whole way;
the 3-bit builds keep about 0.6 to 1 GB of headroom.

The full no-drafter creep, one row per step:

| depth | 4K | 8K | 16K | 25K | 33K | 41K | 49K | 66K | 82K | 98K | 115K | 131K | 147K | 164K |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| ISTA, no drafter, `-c 163840` | 14.14 | 13.82 | 13.25 | 12.83 | 12.39 | 11.95 | 11.51 | 10.90 | 10.24 | 9.69 | 9.19 | 8.72 | **8.30 — last above the floor** | 7.94, floor |

### Drafter sweep on the ISTA build, two depths

One 256-token completion per cell, temperature 0, f16 KV. The shallow
sweep served `-c 106496` at depth 256; the deep sweep served a fixed
`-c 122880` at depth 98,338. No cell had a warmup, so the numbers rank
the cells against each other and do not compare with a creep row.

| cell | tok/s at depth 256 | acceptance | wired at load | tok/s at depth 98K | acceptance | wired |
|---|--:|--:|--:|--:|--:|--:|
| **no drafter** | **14.44** | | 20.2 GB | **9.50** | | 21.2 GB |
| n-max 1 | 14.35 | 90% | 22.1 GB | 9.03 | 86% | 23.0 GB |
| n-max 2 | 13.24 | 80% | 22.2 GB | 8.32 | 79% | 23.1 GB |
| n-max 3 | 12.41 | 68% | 22.4 GB | 7.89 | 71% | 23.2 GB |
| n-max 4 | 11.72 | 64% | 22.5 GB | 7.00 | 62% | 23.3 GB |

A creep row and a single shot at the same depth do not agree: no
drafter reads 9.69 in the creep against 9.50 here, but n-max 3 reads
10.30 in its creep against 7.89 here, with the single shot holding the
smaller allocation. A creep arrives warm and paced; a single shot
arrives cold. Read a fixed-depth sweep cell against cell, never
against a creep.

### MLX, its own creep (2026-08-29, wired limit 24000)

The MLX server ran its own depth ladder on a different day, so its
numbers keep their own table. Its cache is unquantized and the server
offers no KV option.

| depth | 8K | 16K | 22K | 24K | 26K | 28K | ~30K |
|---|--:|--:|--:|--:|--:|--:|---|
| `mlx-community/Qwen3.8-27B-4bit` | 17.1 | 16.4 | 10.23 | 14.79 | 15.19 | **15.29 — last stable** | Metal OOM |

The 22K reading is a dip that recovers by 24K, not a decline. At the
OOM the generation thread dies and `/health` still returns 200. Wired
memory 22.0 GB at 28K.

## Backend comparison: llama-server (GGUF) vs mlx-lm (MLX)

| variant | py tok/s | js tok/s | memory |
|---|--:|--:|--:|
| llama-server Q4_K_M, f16 KV, no MTP | 12.44 | 12.44 | ~21 GB RSS |
| llama-server Q4_K_M + MTP n=3, f16 KV | 16.93 | 15.73 | ~21 GB RSS |
| **mlx-lm MLX 4-bit, f16 KV, no MTP** | **19.69** | **19.58** | **15.5 GB peak** |

## MTP draft depth sweep, the 4-bit build

256 tokens, temperature 0, q8_0 KV, 32K context.

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| off (baseline) | 12.44 | – | 12.44 | – |
| 1 | 12.39 | 91% | 12.02 | 85% |
| 2 | 11.98 | 87% | 10.68 | 72% |
| **3** | **16.79** | **77%** | **15.58** | **69%** |
| 4 | 16.33 | 75% | 13.03 | 55% |
| 6 | 13.12 | 61% | 10.21 | 44% |
| 7 | 12.73 | 53% | 10.16 | 40% |

## Reasoning effort (chat endpoint, 1024-token replies)

| effort | py tok/s | js tok/s | acceptance |
|---|--:|--:|--:|
| xhigh (default) | 14.44 | 13.96 | 58–61% |
| **medium** | **17.50** | **16.30** | **73–81%** |

At medium effort the llama peak stays at n-max 3:

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| **3** | **17.52** | **81%** | **16.31** | **73%** |
| 4 | 16.57 | 75% | 14.86 | 65% |
| 6 | 13.44 | 61% | 11.60 | 51% |

## KV cache: q8_0 vs f16 (at n-max 3)

| KV type | py tok/s | js tok/s | quality |
|---|--:|--:|---|
| q8_0 | 16.79 | 15.58 | near-lossless |
| **f16** | **16.93** | **15.73** | **lossless** |

Shallow only. At depth the gap opens: 7.1 tok/s at 32K for q8_0 against
16.4 for f16, at almost the same wired memory.

---

Method: fresh server start per configuration; identical curl per run;
temperature 0. Full raw numbers in
[the benchmarks](../benchmarks/qwen3.8-27b.md). Cross-model picks on
[the comparison page](../comparison.md).
