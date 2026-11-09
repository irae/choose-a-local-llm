# Run 33 results

The run tests Arete Q3_K_M and S5-nano Q8_0 on arrietty with official
llama.cpp stable v0.9.0. Full quality and agent results are pending.

## Machine setup

The official mise runtime is v0.9.0, build b12110, commit
`cd959bae99ff4bed22bef2604f45241c09bbb8c8`. It reports CUDA0 and the
required reasoning-budget, Jinja and router flags. The idle official
router stopped before the run. The Linux start sample was 787 MiB VRAM
used, 25,997 MiB available RAM, and 0 MiB swap used. GitHub auth and
pi 1.5.0 pass. The corpus server returned HTTP 200.

| model | pinned file | bytes | sha256 | tokenizer revision |
|---|---|---:|---|---|
| Arete | `NousResearch_Arete-27B-Q3_K_M.gguf` | 13165067264 | `b3059ba64a9171cc6e3b8d18f3e1f71e1d9efe06cf0ef074bdbab2ee6947e4c6` | `108f0afbdcfaa1ceeda4a635004304dfff6d4da2` |
| S5-nano | `S5-nano-Q8_0.gguf` | 4610580032 | `f82c0edcb4fa74dc2db7246ef0532f23288943f9f88ec4066b77b1cba307354f` | `ae981dc208f3bba2939c4cf242fab3e9a83e4938` |

The S5-nano GGUF contains one `nextn` head. MTP remains disabled.
No direct cache-quality evidence was found for either fine-tune.

## S5-nano KV feedback

Both cache types loaded at `-c 34816` with full GPU offload arguments.
The resolved child arguments contain no CPU-MoE or tensor-placement
override. The server logs do not print a layer count. The coordinator
accepted the resolved arguments, successful completion and GPU
allocation as operational full-offload evidence. The q8_0 smoke and
speed run used the same pinned Q8_0 model file as the f16 run.

| KV cache | 4K prefill | 4K decode | 8K decode | 16K decode | 24K decode | 32K decode | GPU memory used at 4K / 32K | smoke |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| f16 | 6197.63 tok/s | 77.95 tok/s | 76.17 tok/s | 72.25 tok/s | 68.98 tok/s | 66.02 tok/s | 6641–6647 / 6617 MiB | 3/4, 0 empty |
| q8_0 | 6141.07 tok/s | 77.45 tok/s | 75.68 tok/s | 72.28 tok/s | 69.05 tok/s | 66.02 tok/s | 6227–6233 / 6233 MiB | 3/4, 0 empty |

The smoke results read LEVEL at the same 16,384-token budget. The
coordinator selected q8_0 because the speed curves are within 10% and
both types loaded at `-c 34816`. See the
[KV decision](results/s5-kv-decision.md).
Raw results, memory logs, server logs, resolved arguments, warmup
responses and smoke files are in `results/`.

Swap used was 0 MiB at machine start. It rose to 13,288 KiB before the
first timed cell. It stayed at 13,288 KiB before and after every timed
S5 cell. The coordinator accepted the throughput readings. This does
not show swap-free setup or establish a maximum memory ceiling.

The coordinator selected S5 q8_0 for s5-depth. Use the measured
s5-depth window for the tool smoke and full task. Do not use the
provisional site window.

## Arete KV feedback

Both cache types loaded at `-c 34816`. The resolved child arguments
set `--n-gpu-layers 999` and `--fit off`. They contain no CPU-MoE or
tensor-placement override. The warmups completed and returned
`reasoning_content`. The server logs do not print an explicit layer
count. Record this as operational full-offload evidence. Do not claim
an N/N count.

| KV cache | 4K prefill | 4K decode | 8K decode | 16K decode | 24K decode | 32K decode | GPU memory at 4K / 32K | smoke |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| f16 | 889.89 tok/s | 27.90 tok/s | 27.43 tok/s | 26.50 tok/s | 25.62 tok/s | 24.81 tok/s | 15511–15521 / 15521 MiB | 4/4, 0 empty |
| q8_0 | 886.16 tok/s | 27.59 tok/s | 26.89 tok/s | 25.62 tok/s | 24.49 tok/s | 23.39 tok/s | 14591–14601 / 14601 MiB | 4/4, 0 empty |

Both smokes read LEVEL at the same 16,384-token budget. Q8_0 saved
about 920 MiB at 32K. The speed curves stayed within 10%. The
coordinator selected q8_0 for Arete depth. Raw cells, memory logs,
server logs, resolved arguments, warmups, GPU samples and smoke files
are in `results/`.

Swap used was 60,720 KiB before the first Arete speed cell. It fell to
60,532 KiB by the final cell. It did not grow during any measured cell.
This records a premeasurement increase, not swap-free setup or a
maximum memory ceiling.

Smokes are unscored and stay in this run. Add the measured depth
curves, full EvalPlus results and simulator(mendel) artifacts as their
blocks close.

## Arete depth

The q8_0 configuration loaded at `-c 65536`, the model's depth cap.
Its resolved child arguments kept `--n-gpu-layers 999` and `--fit off`.
They had no CPU-MoE or tensor-placement override. A real benchy cell
at depth 64512 passed at 20.07 tok/s. No larger context is in this
run's cap.

| depth | prefill | decode | GPU memory |
|---:|---:|---:|---:|
| 4096 | 886.13 tok/s | 27.60 tok/s | 15771 MiB |
| 24576 | 823.36 tok/s | 24.49 tok/s | 15771 MiB |
| 32768 | 795.26 tok/s | 23.40 tok/s | 15771 MiB |
| 64512 | 701.17 tok/s | 20.07 tok/s | 15771 MiB |

The deepest clean cell was 64512. Its decode speed was above 8 tok/s.
The measured serving context was 65536. The harness window is 61440,
rounded down to 4096. Swap used was 60244 KiB before the 64512 cell
and 60240 KiB after the final cell. It did not grow during any
measured cell. The premeasurement increase remains a deviation. This
does not prove swap-free setup or set a larger memory ceiling.

The run used separate Linux benchy calls. It did not use the slow
context-creep measurement tool.

## Arete tool smoke

The smoke passed at xhigh with pi 1.5.0. It used site id
`arete-27b-q3km`, measured window 61,440 and keep budget 8,192. The
generated config sent `enable_thinking` and `reasoning_effort` through
the chat template. It set no `maxTokens` or `reserveTokens`. The
source entry came from origin/master commit
`6bd14cd19d590b47d72ed2640c4075f479a95371`.

`SMOKE-MENDEL model=arete-27b-q3km level=xhigh task=xtend window=61440 pi=1.5.0 calls=14 distinct=14 longest_run=1 loop=ok:1.00 compactions=0 splits=0 peak=14621 commits=1 clean=yes end=stop wall_s=122 verdict=pass`

This smoke is unscored. It permits the full simulator(mendel) blocks
after the EvalPlus gate. Raw session, config, fixture and logs are in
`results/arete-tool-smoke/`.

## S5-nano depth

The q8_0 configuration loaded at `-c 262144`, the identity table's
depth cap. The resolved child arguments set `--n-gpu-layers 999` and
`--fit off`, with no CPU-MoE or tensor-placement override. The server
used q8_0 K and V caches, high Think mode and an 8192 reasoning
budget. GPU allocation was 11111 MiB after load and 11117 MiB during
the cells, with 4822 MiB free.

| depth | prefill | decode | GPU memory |
|---:|---:|---:|---:|
| 4096 | 6124.64 tok/s | 77.37 tok/s | 11117 MiB |
| 24576 | 5363.69 tok/s | 69.00 tok/s | 11117 MiB |
| 32768 | 5042.75 tok/s | 66.01 tok/s | 11117 MiB |
| 65536 | 4062.74 tok/s | 56.76 tok/s | 11117 MiB |
| 131072 | 2919.71 tok/s | 44.29 tok/s | 11117 MiB |
| 196608 | 2276.98 tok/s | 36.16 tok/s | 11117 MiB |
| 245760 | 1952.74 tok/s | 31.76 tok/s | 11117 MiB |
| 261120 | 1870.13 tok/s | 30.59 tok/s | 11117 MiB |

Every cell passed. The deepest clean depth was 261120. Its decode
speed was above 8 tok/s. The measured serving context was 262144. The
harness window is 258048, rounded down to 4096. This is the planned
depth cap, not the card's absolute allocation maximum.

Swap used was 63380 KiB before the model load. It did not grow during
the timed cells. It fell from 61272 KiB before the 245760 cell to
61252 KiB after it. This records the premeasurement swap use. It does
not prove swap-free setup or measure a maximum swap ceiling. Deviation:
swap was in use before the model load.

The run used separate Linux benchy calls. It did not use the slow
context-creep measurement tool. Raw cells, memory samples, resolved
arguments, warmup, GPU samples and server log are in
`results/s5-depth-c262144-*`.

## S5-nano tool smoke

The smoke used pi 1.5.0, S5-nano q8_0, high Think, serving context
262144, harness window 258048 and pi's default keep value of 20000.
It set no `maxTokens` or `reserveTokens`. Its entry came from
origin/master commit `ad3d1f750d9f7b91e982884985b24829230db81e`.
GitHub auth passed. The watcher read the server log and live session.

`SMOKE-MENDEL model=s5-nano-q8 level=high task=xtend window=258048 pi=1.5.0 calls=40 distinct=39 longest_run=1 loop=ok:0.92 compactions=0 splits=0 peak=24357 commits=0 clean=no end=stop wall_s=121 verdict=fail`

The smoke failed because the fixture had no new commit and three
modified files. The session shows that the model ran Git add and commit
commands against the outer `run33` Git directory. Local commit
`4d74f4d` added the fixture files to the run branch. I reset that
unpushed commit and kept the changed fixture files as evidence. The
loop check passed. This smoke does not permit the S5 full
simulator(mendel) blocks. S5 thinking quality remains eligible.

The diagnostic, fixture, session, loop, config, stdout and watcher
memory files are in `results/s5-tool-smoke/`.

## S5-nano thinking quality

The q8_0 K/V configuration loaded at `-c 262144` with high Think,
reasoning budget 8192 and output budget 16384. The run used the exact
chat-template body
`{"chat_template_kwargs":{"enable_thinking":true}}`. It ran all
164 HumanEval+ problems without calibration. The active wall was
116.3 minutes.

| base pass@1 | plus pass@1 | completion | empty | forced |
|---:|---:|---:|---:|---:|
| 0.811 | 0.726 | 164/164 | 0/164 | 26/164 |

Coordinator correction, 2026-11-09: the report's zero forced count
was incorrect. `thinking-budget.py count` with the fixed budget
message found 26 forced answers in the finish log. The evaluator
has 133 base passes and 119 plus passes. The scores are unchanged.

The base score meets the 0.800 quality threshold. The S5 tool smoke
failed its commit and clean-tree gates, so the full S5
simulator(mendel) blocks remain skipped. Raw and sanitized samples,
finish records, evaluation output and code generation log are in
`results/s5-quality-think/`. Watcher memory is in
`results/s5-quality-think-watch-memory.log`.

## S5-nano Instruct quality

The q8_0 K/V configuration loaded at `-c 262144` with thinking off
and output budget 16384. The chat template set
`enable_thinking` false. The server had no reasoning-budget flag. The
run completed all 164 HumanEval+ problems without calibration. The
active wall was 25.5 minutes.

| base pass@1 | plus pass@1 | completion | empty | forced |
|---:|---:|---:|---:|---:|
| 0.720 | 0.634 | 164/164 | 0/164 | 0/164 |

This off score does not qualify the thinking-on agent row. S5 full
simulator(mendel) remains skipped because the tool smoke failed its
commit and clean-tree gates. Samples, finish records, evaluation,
resolved args, warmup, server log and watcher memory are in
`results/s5-quality-instruct*`.


## Arete xhigh quality

The q8_0 K/V configuration loaded at `-c 65536` with xhigh, reasoning
budget 8192 and output budget 16384. The chat template set
`enable_thinking` true and `reasoning_effort` to xhigh. The run used
all 164 HumanEval+ problems without calibration. The active wall was
204.1 minutes.

| base pass@1 | plus pass@1 | completion | empty | forced |
|---:|---:|---:|---:|---:|
| 0.976 | 0.951 | 164/164 | 0/164 | 7/164 |

The base score meets the 0.800 quality threshold. This result passes
the EvalPlus gate for Arete's thinking-on simulator(mendel) rows. Raw
and sanitized samples, finish records, evaluation output and code
generation log are in `results/arete-quality-xhigh/`. Watcher memory
is in `results/arete-quality-xhigh-watch-memory.log`.


## S5-nano BF16 weights with f16 K/V

The pinned BF16 file loaded with high Think and f16 K/V. The router
served the new BF16 alias from the requested file. The resolved args
set `n-gpu-layers=999` and `fit=off`, without CPU-MoE or tensor
placement overrides. Warmup returned reasoning. The server log has no
explicit layer-count line; the evidence supports an operational
full-offload reading only.

| allocation | probe depth | prefill | decode | peak GPU used | swap change | result |
|---:|---:|---:|---:|---:|---:|---|
| 131072 | 130048 | 2593.16 tok/s | 30.55 tok/s | 13451 MiB | −9 MiB | pass |
| 163840 | 162816 | 2240.69 tok/s | 28.89 tok/s | 14670 MiB | −3 MiB | pass |
| 196608 | 195584 | 2117.08 tok/s | 26.87 tok/s | 15665 MiB | −10 MiB | pass |
| 204800 | 203776 | 2073.56 tok/s | 26.41 tok/s | 15870 MiB | −1 MiB | pass |
| 212992 | — | — | — | — | — | OOM: 282.02 MiB compute buffer |
| 229376 | — | — | — | — | — | OOM: 7168 MiB KV buffer |
| 262144 | — | — | — | — | — | OOM: 8192 MiB KV buffer |

The trial's largest passing allocation was 204800. The cell at 203776
decoded at 26.41 tok/s. The selected clean depth is 203776, and the
window is 200704. This is the bound tested in this run, not the card's
absolute maximum.

| depth | prefill | decode |
|---:|---:|---:|
| 4096 | 4458.05 tok/s | 45.68 tok/s |
| 24576 | 4156.59 tok/s | 42.46 tok/s |
| 32768 | 3983.80 tok/s | 41.35 tok/s |
| 65536 | 3400.07 tok/s | 37.31 tok/s |
| 131072 | 2617.87 tok/s | 31.23 tok/s |
| 203776 | 2073.56 tok/s | 26.41 tok/s |

The q8_0/q8_0 baseline used `c=262144`, window 258048 and decoded
66.01 tok/s at 32768. The BF16/f16 configuration used `c=204800`,
window 200704 and decoded 41.35 tok/s at 32768, 37% lower. Both the
weights and KV cache changed. This result cannot attribute the change
to either setting alone. The setup swap use rose 214 MiB while loading;
timed cells had no observed swap growth. Raw cells and memory samples
are in `results/s5-bf16-f16-depth-*`; router output is in
`results/server-s5-bf16-f16.log`.


### BF16/f16 EvalPlus smoke

The BF16/f16 config at `c=204800` passed 4/4 fixed problems with
0 empty answers. It used the 200704 measured window, high Think,
reasoning budget 8192, output budget 16384 and no calibration.
HumanEval/53, /45, /34 and /129 passed. The Q8_0/q8_0 baseline passed
3/4 with 0 empty answers. The BF16/f16 config reads better on this
four-problem subset only. This smoke is unscored and does not establish
full coding quality. Samples, evaluator output, stdout, watcher memory
and server evidence are in `results/s5-bf16-f16-eval-smoke/` and
`results/server-s5-bf16-f16.log`.


### BF16/f16 simulator(mendel) smoke

The BF16/f16 config failed the `xtend` smoke's commit and clean-tree
gate. The exact line is:

`SMOKE-MENDEL model=s5-nano-bf16-f16 level=high task=xtend window=200704 pi=1.5.0 calls=57 distinct=45 longest_run=1 loop=ok:0.38 compactions=0 splits=0 peak=31850 commits=n/a clean=n/a end=stop wall_s=308 verdict=fail`

The isolated pi config used alias `s5-nano-bf16-f16`, the BF16 file,
window 200704, default keep 20000 and no `maxTokens` or
`reserveTokens`. The session records Git operations against the outer
run33 worktree after the model removed the fixture's `.git` directory.
Local commit `17aa1b31` was removed before the block push. The fixture,
session, generated config without copied credentials, loop report,
watcher memory and server log remain as evidence. The earlier Q8_0
smoke also failed its commit and clean-tree gate. The BF16/f16 trial's
depth and smoke blocks closed without a full EvalPlus or
simulator(mendel) row. The owner later requested the full thinking-on
EvalPlus row below. No BF16/f16 simulator(mendel) row was run.

### BF16/f16 full EvalPlus, thinking on

At the owner-selected allocation `c=65536`, the S5 BF16 weights with
f16 K/V scored **0.841 base / 0.774 plus** on all 164 EvalPlus
problems. The run forced 31 answers and produced 0 empty answers. It
used high Think, explicit `enable_thinking=true`, an 8192 reasoning
budget, the fixed budget message, 16384 output tokens and temperature
0. The selected allocation is not a measured depth ceiling.

The resolved arguments set `n-gpu-layers=999` and `fit=off`, with no
CPU-MoE or tensor placement override. The router log has no explicit
layer-count line. Record this as operational full-offload evidence;
do not infer an N/N count or infer placement from VRAM alone.

The Q8_0/q8_0 high-thinking baseline scored 0.811 base / 0.726 plus,
with 26 forced and 0 empty answers. This run changed both weights and
KV type, so the score difference does not isolate either change.
Active wall time was 221.2–222.1 minutes across the interrupted parts;
the first part's exact stop time is bounded by its last log update and
the first no-process check. The active-part timestamps are in
`state.md`.

The pinned file hash, resolved arguments, warmups, codegen logs, finish
records, samples, evaluator output, watcher memory and router logs are
in `results/`.

The owner requested a port migration to 8888. The full evaluation had
already completed at 15:15:28 UTC. At the 15:23:16 UTC check, no run
process or listener remained. All 164 unique task IDs are preserved.
No generation restarted while the owner prepares the port update.


## Arete simulator(mendel)

NOT STARTED. The owner deferred the guided and blind rows to a future run. Neither row has a partial result or score. The owner directed cleanup of the aborted guided run. We removed its outputs, generated pi config, watcher, task worktree and local branches. We kept completed Arete depth, tool-smoke and xhigh EvalPlus evidence, and all S5 evidence. The run router and Arete child stopped. Port 8080 is closed. The first post-stop sample showed 858 MiB used and 15,081 MiB free.

Cleanup follow-up, 2026-11-09: We stopped the stale run-owned `socat` forwarder on port 8081 (PID 447875). Both ports are closed. The final VRAM sample showed 782 MiB used and 15,157 MiB free. No test restarted.

## S5 Q8_0/f16 MTP performance

The continuation used the pinned Q8_0 GGUF, official llama.cpp b12110,
high Think, f16 K/V, one slot, `n-gpu-layers=999`, `fit=off`, flash
attention and no projector. It loaded no vision file. The measured curves
use the same real-text corpus and two timed repetitions. The table gives
the two measured MTP requests; per-cell files in `results/` hold prefill,
allocation, GPU and host memory, exact swap readings, metrics and the
server log slice. The complete per-arm logs are also in `results/`.

| n-max | 4K decode | acceptance | 32K decode | acceptance | 130048 decode | acceptance |
|---:|---:|---:|---:|---:|---:|---:|
| no draft | 77.73 tok/s | — | 66.03 tok/s | — | 43.47 tok/s | — |
| 1 | 103.92 tok/s | 214/295, 72.5%, n=2 | 89.04 tok/s | 212/296, 71.6%, n=2 | 59.87 tok/s | 214/295, 72.5%, n=2 |
| 2 | 101.79 tok/s | 245/528, 46.4%, n=2 | 89.92 tok/s | 251/513, 48.9%, n=2 | 61.07 tok/s | 262/504, 52.0%, n=2 |
| 3 | 96.83 tok/s | 260/743, 35.0%, n=2 | 91.73 tok/s | 284/671, 42.3%, n=2 | 60.64 tok/s | 280/687, 40.8%, n=2 |

N-max 1 is the shallow winner. N-max 2 is the deep winner. N-max 3
crossed the n-max 2 result at 32K, so the n-max 3 comparison completed.
The control was slower at all three tuning depths.

All three selected configurations passed an allocation of `c=262144`
with a real `d=261120` cell. Q8_0 no-draft measured 29.73 decode tok/s
with 14144 MiB VRAM used and 1795 MiB free. N-max 1 measured 37.98
tok/s with 15648 MiB used and 291 MiB free; its two measured requests
accepted 191 of 317 drafted tokens (60.3%, n=2). N-max 2 measured 43.91
tok/s with 15698 MiB used and 241 MiB free; its measured requests
accepted 266 of 484 drafted tokens (55.0%, n=2). Swap fell in all three
allocation cells. The per-cell memory logs record available host memory
and exact swap readings.

The full curves used allocation `c=262144` and depths 4096, 8192,
16384, 24576, 32768, then 16384-token increments, and the final
261120-token cell. N-max 1 stopped after swap grew 820 KiB at 147456;
its last clean depth was 131072 at 57.43 tok/s. N-max 2 and no draft
completed the full curve. Both passed the final 261120-token cell.
The deepest clean depth was 261120 at 43.91 tok/s for n-max 2 and
29.73 tok/s for no draft. Their derived 4096-token harness windows are
258048. N-max 1's derived window is 131072.

| arm | depth | prefill tok/s | decode tok/s | accepted/drafted | requests | cell |
|---|---:|---:|---:|---:|---:|---|
| MTP1 | 4096 | 5564.88 | 95.43 | 193/316, 61.1% | 2 | clean |
| MTP1 | 8192 | 5545.74 | 91.90 | 188/321, 58.6% | 2 | clean |
| MTP1 | 16384 | 5252.76 | 91.25 | 199/311, 64.0% | 2 | clean |
| MTP1 | 24576 | 4947.63 | 91.44 | 220/288, 76.4% | 2 | clean |
| MTP1 | 32768 | 4665.52 | 89.22 | 215/294, 73.1% | 2 | clean |
| MTP1 | 49152 | 4167.15 | 80.84 | 210/298, 70.5% | 2 | clean |
| MTP1 | 65536 | 3756.79 | 70.15 | 188/321, 58.6% | 2 | clean |
| MTP1 | 81920 | 3408.97 | 74.39 | 226/283, 79.9% | 2 | clean |
| MTP1 | 98304 | 3135.42 | 69.45 | 224/285, 78.6% | 2 | clean |
| MTP1 | 114688 | 2893.34 | 60.78 | 204/305, 66.9% | 2 | clean |
| MTP1 | 131072 | 2687.59 | 57.43 | 205/304, 67.4% | 2 | clean |
| MTP1 | 147456 | 2508.95 | 54.86 | 207/303, 68.3% | 2 | swap +820 KiB; invalid |
| MTP1 | 261120 | 1710.80 | 37.98 | 191/317, 60.3% | 2 | separate ceiling cell, clean |
| MTP2 | 4096 | 5531.86 | 100.15 | 245/528, 46.4% | 2 | clean |
| MTP2 | 8192 | 5522.16 | 99.06 | 246/525, 46.9% | 2 | clean |
| MTP2 | 16384 | 5255.01 | 103.04 | 271/476, 56.9% | 2 | clean |
| MTP2 | 24576 | 4948.84 | 103.83 | 283/450, 62.9% | 2 | clean |
| MTP2 | 32768 | 4660.08 | 90.41 | 256/505, 50.7% | 2 | clean |
| MTP2 | 49152 | 4152.87 | 95.15 | 287/444, 64.6% | 2 | clean |
| MTP2 | 65536 | 3753.46 | 80.23 | 261/494, 52.8% | 2 | clean |
| MTP2 | 81920 | 3414.01 | 78.64 | 276/462, 59.7% | 2 | clean |
| MTP2 | 98304 | 3129.29 | 72.80 | 266/485, 54.8% | 2 | clean |
| MTP2 | 114688 | 2888.12 | 59.69 | 236/545, 43.3% | 2 | clean |
| MTP2 | 131072 | 2681.79 | 59.75 | 251/516, 48.6% | 2 | clean |
| MTP2 | 147456 | 2501.68 | 60.88 | 269/478, 56.3% | 2 | clean |
| MTP2 | 163840 | 2344.27 | 53.13 | 248/523, 47.4% | 2 | clean |
| MTP2 | 180224 | 2204.63 | 53.55 | 256/505, 50.7% | 2 | clean |
| MTP2 | 196608 | 2083.69 | 50.76 | 261/495, 52.7% | 2 | clean |
| MTP2 | 212992 | 1972.60 | 47.16 | 254/512, 49.6% | 2 | clean |
| MTP2 | 229376 | 1873.14 | 45.63 | 256/504, 50.8% | 2 | clean |
| MTP2 | 245760 | 1782.59 | 47.98 | 277/462, 60.0% | 2 | clean |
| MTP2 | 261120 | 1703.33 | 43.91 | 266/484, 55.0% | 2 | separate ceiling cell, clean |

The no-draft curve used allocation `c=262144`. The separate ceiling
cell at 261120 tokens was reused as the final curve cell. The per-cell
files include allocation, GPU memory, host available memory, swap
before and after, and the raw benchy output.

| depth | prefill tok/s | decode tok/s | status |
|---:|---:|---:|---|
| 4096 | 6168.36 | 77.99 | clean |
| 8192 | 6132.34 | 75.92 | clean |
| 16384 | 5813.65 | 72.21 | clean |
| 24576 | 5471.93 | 68.99 | clean |
| 32768 | 5157.57 | 66.15 | clean |
| 49152 | 4619.70 | 60.79 | clean |
| 65536 | 4173.83 | 56.32 | clean |
| 81920 | 3809.31 | 52.34 | clean |
| 98304 | 3500.93 | 48.99 | clean |
| 114688 | 3235.19 | 46.02 | clean |
| 131072 | 3009.34 | 43.40 | clean |
| 147456 | 2813.03 | 41.05 | clean |
| 163840 | 2643.50 | 38.94 | clean |
| 180224 | 2488.89 | 37.09 | clean |
| 196608 | 2351.99 | 35.31 | clean |
| 212992 | 2230.01 | 33.74 | clean |
| 229376 | 2123.13 | 32.32 | clean |
| 245760 | 2019.47 | 30.97 | clean |
| 261120 | 1933.83 | 29.73 | separate ceiling cell, clean |

The projector remains theoretical and was not downloaded or loaded.
Its publisher metadata gives 672423104 bytes (about 641 MiB). At
`c=262144`, the no-draft result left 1795 MiB free, so the file size
could fit by itself. N-max 1 and 2 left 291 MiB and 241 MiB free, so
that file size would not fit beside either measured MTP allocation.
MTP1 and MTP2 used 1504 MiB and 1554 MiB more VRAM than no draft at
this allocation. These estimates exclude CUDA and runtime buffers and
image-processing workspace. Vision and image prefill were not tested.

One run-log file was overwritten when the transient router restarted
for the MTP2 curve. The ceiling cell's benchy output, memory snapshots
and before/after metrics remain. The metrics changed by 769 drafted
and 418 accepted tokens across the warmup and three full-text requests;
the two measured requests accepted 266 of 484 drafted tokens. A helper
also used the wrong fallback offset for per-cell MTP server slices.
The complete per-arm router logs retain the curve requests. The
per-cell slices were rebuilt from those logs by depth.
