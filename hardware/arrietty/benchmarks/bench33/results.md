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
| 0.811 | 0.726 | 164/164 | 0/164 | 0/164 |

The base score meets the 0.800 quality threshold. The S5 tool smoke
failed its commit and clean-tree gates, so the full S5
simulator(mendel) blocks remain skipped. Raw and sanitized samples,
finish records, evaluation output and code generation log are in
`results/s5-quality-think/`. Watcher memory is in
`results/s5-quality-think-watch-memory.log`.
