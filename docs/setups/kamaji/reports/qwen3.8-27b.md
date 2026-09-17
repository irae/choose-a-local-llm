# Qwen3.8-27B on M1 Max 32 GB

Backends: llama-server, mlx-lm · [Qwen3.8-27B MLX 4-bit on Hugging Face](https://huggingface.co/mlx-community/Qwen3.8-27B-4bit)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>0.957 / 0.939</b><span>EvalPlus base / plus, Q4_K_M, effort xhigh</span><small>96% completion</small></div>
  <div class="kpi"><b>93 / 100</b><span>Mendel blind, 4-bit GGUF, effort xhigh</span><small>complete, no critical defect</small></div>
  <div class="kpi"><b>147K</b><span>deepest clean depth, ISTA, no drafter</span><small>8.3 tok/s there</small></div>
  <div class="kpi"><b>28K</b><span>MLX memory ceiling, 15.3 tok/s there</span></div>
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
  trap; at effort low it scores 66, partial. Both are single runs.
  Every earlier row ran at effort medium, which this model is no
  longer tested at.
- **Dropping the drafter buys the 3-bit build depth and speed.**
  Without it the ISTA build serves `-c 163840` and holds 8.3 tok/s at
  147K of clean context; with it, 9.7 at 115K. The drafter is slower at
  every depth tried, 12.4 against 14.4 tok/s at depth 256 and 7.9
  against 9.5 at 98K, because acceptance falls faster than the draft
  grows.
- **At effort xhigh the single-turn score is 0.957 / 0.939 on the
  4-bit build and 0.945 / 0.927 on the unsloth 3-bit**, each with a
  few problems that never converged inside the output budget; every
  one of those empties is proven as the budget
  ([limits](../../../benchmarks/evalplus.md#limits-on-local-hardware)).
  The level moves the single-turn score the other way from the agent
  score: on the ISTA build low reads 0.976 / 0.933 and xhigh 0.945 /
  0.921. The project's best base, 0.988 on the AtomicChat build, came
  at effort medium, a level this model is no longer run at.
- Weak point: the slowest model on this hardware. On real text at the
  server's sampling the 4-bit GGUF with its drafter reads 11.8 tok/s
  shallow and 8.6 at 65.5K, and the 3-bit without one 14 shallow and
  8.3 at 147K; prompt processing is poor (~123 tok/s). MLX holds 14 to
  17 tok/s across its window and OOMs between 28K and 30K.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-bartowski-q4km" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" top-deep /> | 25.0 GB | <ScoreCell value="0.957/0.939" sub="96% completion" /> | <ScoreCell value="93" pill="mendel-blind" top /> | <span title="EvalPlus 8h30 · Mendel 3h33">12h04</span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="medium" page="/binaries/qwen38-bartowski-q4km" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" top-deep /> | 25.0 GB | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="87" pill="mendel-blind" top /> | <span title="EvalPlus 3h32 · Mendel 2h09">5h42</span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" top /> | **147k** | speed | <TokCell shallow="13.60" deep="7.97" /> | 25.5 GB | <ScoreCell value="0.945/0.927" sub="100% completion" /> | <ScoreCell value="90.5" pill="mendel-blind" top /> | <span title="EvalPlus 13h36 · Mendel 3h05">16h41</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" top /> | **147k** | speed | <TokCell shallow="14.1" deep="8.1" /> | **24.4 GB** | <ScoreCell value="0.945/0.921" sub="97% completion" /> | <ScoreCell value="80.5" pill="mendel-blind" top /> | <span title="EvalPlus 9h43 · Mendel 1h49">11h33</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/binaries/qwen38-ista-iq3s-mtp" top /> | **128k** | mem | <TokCell shallow="15.1" deep="9.7" stale top-shallow top-deep /> | **24.2 GB** | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" /> | <span title="EvalPlus 3h12 · Mendel 2h15">5h27</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" page="/binaries/qwen38-ista-iq3s-mtp" /> | **147k** | speed | <TokCell shallow="14.1" deep="8.1" /> | **24.4 GB** | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 2h43">5h10</span> |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" page="/binaries/qwen38-atomicchat-ad-iq3s" /> | 104k | mem | <TokCell shallow="14.3" deep="9.6" top-deep /> | **24.1 GB** | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 3h11 · Mendel 1h00">4h10</span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" page="/binaries/qwen38-mlx-4bit" /> | 25k | mem | <TokCell shallow="17.3" deep="14.8" top-shallow top-deep /> | **22.0 GB** | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5†" note="13%" pill="mendel-blind" /> | <span title="EvalPlus 2h09 · Mendel 1h25">3h34</span> |

† from an earlier serving config or method; re-run pending.

Rows below 100 percent completeness. Completeness counts three measurements: tok/s, EvalPlus and Mendel.

| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" page="/binaries/qwen38-mlx-4bit" top /> | **25k** | mem | <TokCell shallow="17.3" deep="14.8" top-shallow top-deep /> | **22.0 GB** | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 3h32 · Mendel —">3h32†</span> |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-bartowski-q4km" />

Curve shared with the effort-medium row: same server, same weights, no drafter since 2026-09-13; the harness sets the level per request. The Mendel row and the EvalPlus run below ran with the drafter at n-max 3, which changes speed and not output. Mendel blind at effort xhigh, the model's own default, measured 2026-09-11: 93/100, complete 8/8, on the 65536 window, no critical defect, one medium, peak context 61572, sampling temperature 1.0 and top_p 0.95 from the server default. The highest Mendel score of any local row. EvalPlus at effort xhigh, scored 2026-09-12 at budget 30000 on the same build served at `-c 32768`: 0.957/0.939, six empty, every one a completion that hit the 30000-token cap, in 8h30 of active wall time; its own score, above the ISTA build's 0.945/0.921 at the same level. Under a server thinking budget of 30000 tokens (the derive cap; the calibration's longest converged reasoning ran 22947 tokens; answer budget 2048, `max_tokens` 32048; the thinking-budget test, 2026-09-17), the same file, drafter and level scored 0.982/0.951 with no empty answer in 447.8 minutes: 3 problems hit the budget and were forced to answer, and all 3 passed the base tests. The natural run at 30000 left 6 empty in 510.3 minutes. The one forced answer that failed the plus tests hits the 30000 cap without the budget too, so the budget cost no answer and stands. The owner's word on how a budgeted score is shown is pending.

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="medium" page="/binaries/qwen38-bartowski-q4km" />

pi id `qwen3.8-27b`. Re-measured 2026-09-08 at wired limit 25000: `-c 73728` serves, `-c 81920` OOMs at load, and decode and draft acceptance stay flat across the whole served range, so the boundary is memory alone. Speeds read with llama-benchy on real code text at the server's own sampling: no drafter 12.4 tok/s at 4K and 9.7 at 65.5K (2026-09-13); the MTP drafter loses at every depth, 11.8 and 8.6 at n-max 3 with 37 to 63 percent acceptance (2026-09-11) and 10.7 and 8.3 at n-max 1, so the served command carries no drafter. The Mendel rows below ran with the drafter at n-max 3 on the same window; the drafter changes speed, not output. Wired 25.0 GB, zero swap growth. The older `-c 49152` was the ceiling at wired 24000. The EvalPlus score is still the MLX effort-medium run, carried by the shared-score rule; this build has no full EvalPlus of its own, so it cannot be read against the two 3-bit builds below, which do. Mendel blind at effort medium: 87/100 at reserve 16384 and window 49152, and 76/100 on the 2026-09-08 re-run at reserve 8192 and window 65536. The two are different configurations, not a repeat: the second failed trap A, which the first passed.

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" />

pi id `qwen3.8-27b-iq3s`. The unsloth 3-bit build the Linux setup serves, revision `4ca7207`, the same file by sha256, run on this machine beside the ISTA 3-bit build. Measured 2026-09-14 at wired limit 25000: `-c 188416` is the largest value that serves (196608 hits a Metal OOM at load); the slow creep runs to 147478 at 8.17 tok/s and stops on the floor at 163858, with no swap growth. Real text with llama-benchy, no drafter: 13.60 tok/s at 4K, 8.19 at 138K, 7.97 at 147K, just under the floor. EvalPlus at effort xhigh, scored 2026-09-15 at budget 20000 on the same build served at `-c 32768`: 0.945/0.927, eight empty of 164, in 615.6 minutes of active time. Same base score as the ISTA build on this Mac and a higher `plus` score, at a smaller budget. A re-run of the eight empty problems on 2026-09-16 proved every one as the output budget, with the answer still coming at 20000 tokens; none was recovered. That re-run adds 200 minutes to the wall. Mendel blind at effort xhigh: 90.5/100, complete 8/8, with an anomaly — the model merged `master` into its own branch mid-run and imported infrastructure the blind base hides, so the row is not strictly base-comparable. Mendel guided at effort xhigh: 62.5 displayed of 76 raw, a valid partial at the 300-minute wall cap, 5 of 8 libraries. The drafter arms are pending.

```bash
llama-server -hf unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S \
  --alias qwen3.8-27b-iq3s --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 188416 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" />

pi id `qwen3.8-27b-ista`. The same build with the drafter off, measured 2026-09-09 at wired limit 25000. Without the drafter `-c 163840` serves, and the creep runs clean to 147478 tokens at 8.30 tok/s before the speed floor; swap never grew. The drafter is a loss on this build at every depth tried: at depth 256, no drafter reads 14.4 tok/s against 12.4 at n-max 3, and at depth 98338 it reads 9.5 against 7.9, so the no-drafter server is both faster and 33K deeper. Mendel blind at effort xhigh, the model's own default: 80.5/100, complete 8/8, one critical trap, 109 minutes, peak context 117,940 of a 147,456 window, no compaction. Sampling recorded for the first time on this machine: temperature 1.0, top_p 0.95, the values llama-server reads from the model file. EvalPlus at effort xhigh, scored 2026-09-10 at budget 30000 on the same build served at `-c 32768`: 0.945/0.921, five empty, every one a completion that hit the 30000-token cap, in about 9h43 of active wall time; below the medium and low rows on both metrics. More thinking does not help this model on short single-turn problems.

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b-ista --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 163840 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/binaries/qwen38-ista-iq3s-mtp" />

A 3-bit build of the same model, revision `d562806`, with its drafter on. Measured 2026-09-08 at wired limit 25000. Clean depth 114718 at 9.7 tok/s; `-c 131072` serves. `n-max 3` is the best drafter setting on this build, confirmed by a sweep: 4 and 6 were both slower. EvalPlus 0.976/0.945, one empty at budget 8192, its own score and not a carried one. Mendel blind at effort medium: 76.5/100, complete 8/8, window 114688. It failed trap A in the same shape as the 4-bit row's own re-run. The drafter costs this build speed at every depth, so the two no-drafter rows below are the served pick; this row stays as the drafter measurement and the medium score.

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 131072 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" page="/binaries/qwen38-ista-iq3s-mtp" />

Curve shared with the effort-xhigh row: same server, same weights; the harness sets the level per request. Mendel blind at effort low: 66/100, partial, 7 of 8 libraries, two traps hit, 163 minutes, peak context 130,154 of the same window. The run ended on the harness's 25-minute turn cap during a full test suite, not on the rubric. Low scored lower than xhigh and spent more context and more wall time doing it. EvalPlus at effort low, scored 2026-09-10 at budget 8192 on the same build served at `-c 32768`: 0.976/0.933, one empty, in 2h23; level with the medium row on base and one problem lower on plus. The calibration converged on all 10 problems with a 3634-token maximum.

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b-ista --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 163840 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" page="/binaries/qwen38-atomicchat-ad-iq3s" />

A second 3-bit build of the same model, revision `ca10ebc`. Measured 2026-09-08 at wired limit 25000. Its sweep reached 98338 and never hit a stop condition, so that depth is where the sweep ended and not a ceiling this machine refused to pass. Speeds read 2026-09-12 with llama-benchy on real code text: no drafter 14.3 tok/s at 4K and 9.6 at 98K; the MTP drafter loses at every depth on real text, 12.2 and 8.8 at n-max 1, 8.1 and 7.4 at n-max 3 with 35 to 69 percent acceptance, so the served command carries no drafter. The Mendel row below ran with the drafter at n-max 3 on the same window; the drafter changes speed, not output. EvalPlus 0.988/0.927, no empty completions, the best base score of any local build here and its own score, not a carried one. Mendel blind at effort medium: 37.5/100 capped from 74 raw, partial at three of eight libraries. It ended on a repetition loop, five identical searches of a directory that held nothing it wanted.

```bash
llama-server -hf AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S \
  --alias qwen3.8-27b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 106496 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" page="/binaries/qwen38-mlx-4bit" />

Curve shared with the effort-medium row: same server, same weights. The reasoning effort changes the output, not the decode speed at a depth.

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
  --chat-template-args '{"reasoning_effort":"low"}' --prompt-cache-size 2 --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" page="/binaries/qwen38-mlx-4bit" />

Set the harness compaction threshold at ~26K. No Mendel run is planned: the agent task needs about 46K of context and this server holds 26K, so every attempt on this build was partial or invalid, and medium is no longer run on this model.

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
  --reasoning-effort medium --port 8081
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
MLX build; it stays a single-turn option in 22 GB. The weights are
not the problem here: the MLX build scores level with the GGUF builds
on EvalPlus, so its agent record is the window and the Metal ceiling
([quantization](../../../methodology/quantization.md)).

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

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/binaries/qwen38-atomicchat-ad-iq3s" />](../benchmarks/qwen3.8-27b.md) | 8886 | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | none | <TokCell shallow="14.3" deep="9.6" /> | 3h11 |
| [<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" page="/binaries/qwen38-mlx-4bit" />](../benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | none | <TokCell shallow="17.3" deep="14.8" /> | 3h32 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/binaries/qwen38-ista-iq3s-mtp" />](../benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | 1 budget | <TokCell shallow="15.1" deep="9.7" /> | 3h12 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" page="/binaries/qwen38-ista-iq3s-mtp" />](../benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | 1 budget | <TokCell shallow="14.1" deep="8.1" /> | 2h27 |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" page="/binaries/qwen38-bartowski-q4km" />](../benchmarks/qwen3.8-27b.md) | 30000 | <ScoreCell value="0.957/0.939" sub="96% completion" /> | 6 budget | <TokCell shallow="12.4" deep="9.7" /> | 8h30 |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" />](../benchmarks/qwen3.8-27b.md) | 20000 | <ScoreCell value="0.945/0.927" sub="95% completion" /> | 8 budget | <TokCell shallow="13.60" deep="7.97" /> | 13h36 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" />](../benchmarks/qwen3.8-27b.md) | 30000 | <ScoreCell value="0.945/0.921" sub="97% completion" /> | 5 budget | <TokCell shallow="14.1" deep="8.1" /> | 9h43 |
<!-- gen:model-evalplus:end -->

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
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" page="/binaries/qwen38-bartowski-q4km" /> | blind-v1.1 | 64k | **93** | 8/8/done | 213.3 | 10,077k | 62k | 3 | 272 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" /> | blind-v1.1 | 144k | **90.5** | 8/8/done | 185.4 | 15,060k | 143k | 1 | 240 | 19 |  |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/binaries/qwen38-bartowski-q4km" /> | blind-v1.1 | 48k | **87** | 8/8/done | 129.3 | 5,947k | 46k | 4 | 210 | 10 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | 144k | **80.5** | 8/8/done | 109.4 | 10,819k | 118k | 0 | 193 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | 112k | **76.5** | 8/8/done | 135.2 | 7,890k | 89k | 0 | 195 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/binaries/qwen38-bartowski-q4km" /> | blind-v1.1 | 64k | **76** | 8/8/done | 97.8 | 5,008k | 60k | 1 | 173 | 12 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | 144k | **66** | 7/8/partial | 163.3 | 11,426k | 130k | 0 | 214 | 15 |  |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" page="/binaries/qwen38-mlx-4bit" /> † | blind-v1.0 | 26k | **37.5** (raw 80) | 3/8/partial | 253.5 | 1,777k | 24k | 0 | 135 | 6 |  |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/binaries/qwen38-atomicchat-ad-iq3s" /> | blind-v1.1 | 96k | **37.5** | 3/8/partial | 59.8 | 7,025k | 70k | 0 | 189 | 7 |  |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" page="/binaries/qwen38-mlx-4bit" /> † | blind-v1.1 | 26k | **12.5** (raw 67.5) | 1/8/partial | 85.2 | 610k | 24k | 0 | 29 | 1 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" page="/binaries/qwen38-mlx-4bit" /> † | guided-v2.1 | 26k | **75** (raw 84) | 6/8/partial | 153.8 | 1,123k | 23k | 0 | 95 | 6 |  |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" /> | guided-v3.0 | 144k | **62.5** | 5/8/partial | 300.0 | 16,902k | 143k | 1 | 243 | 5 |  |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" page="/binaries/qwen38-mlx-4bit" /> † | guided-v3.0 | ?k | **0** (raw 34) | 0/8/invalid | 261.3 | 1,254k | 30k | 0 | 48 | 0 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.

† a 26624-token window with a 16384-token output budget, our config arithmetic, not the model
<!-- gen:model-mendel:end -->

The full table and the rubric are on [the Mendel page](../../../benchmarks/mendel.md).

The MLX build gives a 26624-token window. That window stopped the low-effort run.

## Decode speed vs used context

<ModelSpec base="Qwen3.8-27B" server="llama-server" kv="f16" hide="quant,publisher,drafter,effort" />

The llama arm, in the shape of
[the comparison table](../comparison.md#decode-speed-vs-used-context-the-8-tok-s-usability-floor).
Slow creeps 2026-09-08 and 2026-09-09, wired limit 25000. Every row is
f16 KV; the drafter rows run the MTP drafter at n-max 3, which each
build's own sweep confirmed as the best drafter setting.

| config | @ 4-8K | @ 16K | @ 33K | @ 49K | @ 98K | capped by |
|---|--:|--:|--:|--:|--:|---|
| **Q4_K_M bartowski, MTP n-max 3, `-c 73728`** | **11.8** | **16.1** | **16.4** | **15.0** | | mem — swap grew at 73.7K; clean to 65.5K at 8.6 tok/s. The 4K and 65.5K cells were read 2026-09-11 with llama-benchy on real code text at the server's own sampling, acceptance 37 to 63 percent; the others are the creep's readings |
| AD-IQ3_S AtomicChat, MTP n-max 3, `-c 106496` | 15.8 | 14.8 | 13.7 | 12.7 | 10.3 | untested — swept to 98338 and never hit a stop |
| IQ3_S-mtp ISTA, MTP n-max 3, `-c 131072` | 15.1 | 14.7 | 13.7 | 12.7 | 10.3 | mem — swap grew at 131.1K; clean to 114718 at 9.7 tok/s |
| **IQ3_S-mtp ISTA, no drafter, `-c 163840`** | **14.1** | **13.3** | **12.4** | **11.5** | **9.7** | speed — 8.30 at 147478, under the floor at 163858; zero swap the whole way |

Wired memory 25.4 GB for the 4-bit build, 24.1 to 24.4 GB for the
3-bit rows. The 4-bit build runs against the wired limit the whole way;
the 3-bit builds keep about 0.6 to 1 GB of headroom.

The full no-drafter creep, one row per step:

| depth | 4K | 8K | 16K | 25K | 33K | 41K | 49K | 66K | 82K | 98K | 115K | 131K | 147K | 164K |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| ISTA, no drafter, `-c 163840` | 14.14 | 13.82 | 13.25 | 12.83 | 12.39 | 11.95 | 11.51 | 10.90 | 10.24 | 9.69 | 9.19 | 8.72 | **8.30 — last above the floor** | 7.94, floor |

### Drafter sweep at two depths

<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" hide="drafter,effort" />

One 256-token completion per cell, temperature 0. The shallow
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

The short-prompt drafter sweeps, the reasoning-effort speed read, the
KV cache comparison and the backend comparison of 2026-08-25 are on
[the benchmarks page](../benchmarks/qwen3.8-27b.md).

---

Method: fresh server start per configuration; identical curl per run;
temperature 0. Full raw numbers in
[the benchmarks](../benchmarks/qwen3.8-27b.md). Cross-model picks on
[the comparison page](../comparison.md).
