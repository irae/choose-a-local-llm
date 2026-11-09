# Run 33 state

Planned 2026-11-08. No model test has started.

Read `AGENT.md` for the order and fixed identities. Record each derived
cache choice, allocation ceiling, clean depth and harness window here,
with its source block. Record deviations when they occur.

## Coordinator preparation

The official stable runtime is v0.9.0, build b12110. Its upstream
commit is `cd959bae99ff4bed22bef2604f45241c09bbb8c8`.
The stable release's `nightly-tag.txt` points to this build.
The official CUDA 12.8 archive hashes are:

- server: `4af1e1da23661db4a5b84b29aae16ebc053df689c5b8b1427c4670f2c6406d8c`
- CUDA runtime: `6f1d562086d84ae85df880d3711079ec225602b51d530608e5001600625067dd`

Both downloaded archives matched. CUDA0 was detected by the official
binary. Mise installed the same official archives and verified the
GitHub artifact attestation. The final binary is
`~/.local/share/mise/installs/llama-cpp/b12110/llama-server`.
Its `--version` prints b12110 and `--list-devices` names CUDA0.
The owner's mise install hook links the separate upstream CUDA
libraries into the install root. No binary was compiled or modified.

The coordinator prepares each new site's row and harness map after
its KV block, before the first tool smoke. The runner keeps independent
GPU work queued while that shared change is prepared.

## Machine

- The run uses `/home/irae/.t3/worktrees/choose-a-local-llm/run33` on
  branch `run33`. The main worktree remains on `master`.
- The Linux host has an RTX 5060 Ti with 16,311 MiB VRAM. At the run
  start, `nvidia-smi` showed 787 MiB used and 15,152 MiB free.
- `free -m` showed 25,997 MiB available. Swap used was 0 MiB. Disk
  free space was 34 GiB before the model downloads.
- `results/preflight.log` records the preflight after the idle official
  router stopped. The first preflight found that router idle with no
  loaded model. The helper stopped it. No Prism process was present.
- The preflight app, login-item, wired-limit and sysctl checks are
  macOS-only on this Linux host. The machine config file is absent.
  The direct Linux GPU, memory, swap and disk readings are recorded
  above. GitHub auth passes. Pi is current at 1.5.0.
- The official mise binary is
  `/home/irae/.local/share/mise/installs/llama-cpp/b12110/llama-server`.
  It reports v0.9.0, build b12110, commit
  `cd959bae99ff4bed22bef2604f45241c09bbb8c8`, and CUDA0. Its help
  lists the required reasoning-budget, Jinja and router flags. No
  runtime was compiled or modified.
- `llama-benchy` is 0.4.0. `hf` is 1.31.0. The EvalPlus Python is
  `/home/irae/.local/share/pipx/venvs/evalplus/bin/python`.
- The corpus server runs as PID 421424 on port 8089. The pinned corpus
  hash matches. A local HTTP request returned 200 and 613,339 bytes.

## Files and revisions

| repo | file | revision | bytes | sha256 |
|---|---|---|---:|---|
| `bartowski/NousResearch_Arete-27B-GGUF` | `NousResearch_Arete-27B-Q3_K_M.gguf` | `9762c8502a79bd2b8634735d75f426b9febe092c` | 13165067264 | `b3059ba64a9171cc6e3b8d18f3e1f71e1d9efe06cf0ef074bdbab2ee6947e4c6` |
| `maritaca-ai/S5-nano-GGUF` | `S5-nano-Q8_0.gguf` | `5fd041274829d60aeeba1e2edc4aabb621a432e4` | 4610580032 | `f82c0edcb4fa74dc2db7246ef0532f23288943f9f88ec4066b77b1cba307354f` |

The GGUF files are in the default Hugging Face cache. The Arete
tokenizer snapshot is
`/home/irae/.cache/huggingface/hub/models--NousResearch--Arete-27B/snapshots/108f0afbdcfaa1ceeda4a635004304dfff6d4da2`.
The S5-nano tokenizer snapshot is
`/home/irae/.cache/huggingface/hub/models--maritaca-ai--S5-nano/snapshots/ae981dc208f3bba2939c4cf242fab3e9a83e4938`.
Both snapshots contain metadata and tokenizer files only. No source
safetensors were fetched. The S5 GGUF metadata has
`qwen35.nextn_predict_layers = 1`; its tensor names include
`blk.32.nextn.*`, so the file contains the head. MTP stays disabled.

The cache-quality searches found no direct q8_0-versus-f16 evidence
for either fine-tune. Parent-model evidence does not decide these
cache picks.

## machine-setup

The idle official router stopped cleanly. The official b12110 runtime
reports CUDA0 and the required flags. Both pinned GGUFs and tokenizer
metadata are present and verified. The corpus server is ready. No
model test has run yet.

## s5-kv-feedback

The f16 cache loaded at `-c 34816`. The actual child arguments are in
`results/s5-kv-f16-resolved.json`. They set `--n-gpu-layers 999` and
`--fit off`. They contain no CPU-MoE or tensor-placement override.
The GPU allocation sample is in `results/s5-kv-f16-gpu-allocation.log`.
The warmup response is in `results/s5-kv-f16-warmup.json`; it names
`s5-nano-q8` and includes `reasoning_content`. The log has no explicit
layer-count line. The coordinator accepted the resolved arguments,
successful completion and GPU allocation as operational full-offload
evidence. Do not report an N/N layer count.

The runtime warned that `enable_thinking` in `chat-template-kwargs` is
deprecated. The runbook's explicit JSON remains in use, and the real
completion includes reasoning. The model log marks `blk.32.nextn.*`
tensors unused. MTP stays disabled.

At router startup, the parent log reported
`tensor 'output.weight' has invalid ggml type 143` while it checked
existing cache entries. The router still listed the S5 preset. The S5
child loaded and passed its warmup. The cache entry that caused this
message was not identified.

The f16 decode readings were 77.95 tok/s at 4K, 76.17 at 8K, 72.25
at 16K, 68.98 at 24K and 66.02 at 32K. All cells completed. The smoke
passed 3 of 4 problems, with 0 empty answers and 14,786 completion
tokens. Its wall time was 210.5 s.

The q8_0 child arguments are in `results/s5-kv-q8-resolved.json`.
They set `--n-gpu-layers 999` and `--fit off`, with no CPU-MoE or
tensor-placement override. The GPU allocation sample is in
`results/s5-kv-q8-gpu-allocation.log`; it reports 5,288 MiB. The warmup
response is in `results/s5-kv-q8-warmup.json`. Neither server log prints
an explicit layer-count line.

The q8_0 decode readings were 77.45 tok/s at 4K, 75.68 at 8K, 72.28
at 16K, 69.05 at 24K and 66.02 at 32K. All cells completed. The smoke
passed 3 of 4 problems, with 0 empty answers and 11,807 completion
tokens. Its wall time was 172.7 s. The two smoke lines read LEVEL.
Both types loaded at `-c 34816`, and their 32K decode speeds differ by
less than 10%. The coordinator selected q8_0 for S5 depth. See
[`results/s5-kv-decision.md`](results/s5-kv-decision.md).

Swap used was 0 MiB at machine start. It rose to 13,288 KiB before the
first timed S5 cell. It stayed at 13,288 KiB before and after every
timed cell. The coordinator accepted the throughput readings. This
does not show swap-free setup or establish a maximum memory ceiling.

The coordinator selected q8_0 for S5 depth. The site entry is
`s5-nano-q8`. Its provisional site window is 32,768 tokens. Use the
measured s5-depth window for the tool smoke and full task.

## S5 coordinator decision

The timed cells are accepted with the pre-cell swap increase recorded
as a deviation. The full decision is in
[`results/s5-kv-decision.md`](results/s5-kv-decision.md). The depth
block must set the final serving context and harness window. The new
pending site row and pi id are `s5-nano-q8`. The initial 32,768-token
harness window comes from the short test, not a full depth ceiling.
The newer depth result must replace it.

## arete-kv-feedback

Arete loaded both cache types at `-c 34816`. The server used the pinned
Q3_K_M file and returned reasoning on each warmup. The resolved child
arguments set `--n-gpu-layers 999` and `--fit off`. They contain no
CPU-MoE or tensor-placement override. Both configurations completed a
real completion. The server logs have no explicit layer-count line.
Record operational full-offload evidence. Do not claim an N/N count.

The f16 decode readings were 27.90 tok/s at 4K, 27.43 at 8K, 26.50 at
16K, 25.62 at 24K and 24.81 at 32K. The matching prefill readings
were 889.89, 884.47, 858.28, 830.65 and 803.46 tok/s. Every cell
completed. The 4K and 32K GPU samples were 15,511–15,521 MiB and
15,521 MiB. The smoke passed 4 of 4 problems, with 0 empty answers
and 7,639 completion tokens. Its wall time was 294.8 s.

The q8_0 decode readings were 27.59 tok/s at 4K, 26.89 at 8K, 25.62
at 16K, 24.49 at 24K and 23.39 at 32K. The matching prefill readings
were 886.16, 880.07, 852.59, 823.11 and 795.03 tok/s. Every cell
completed. The 4K and 32K GPU samples were 14,591–14,601 MiB and
14,601 MiB. The smoke passed 4 of 4 problems, with 0 empty answers
and 8,519 completion tokens. Its wall time was 328.9 s. Both smoke
lines read LEVEL. At 32K, q8_0 saved about 920 MiB and its speed was
within 10% of f16. The coordinator selected q8_0 for Arete depth.

The first run router used PID 432837 with child 432912 and socat PID
432838. The f16 smoke reload used router PID 437251 with child 437298
and socat PID 437252. Both run routers stopped after their cells.

Swap used was 60,720 KiB before the first Arete speed cell. It stayed
near 60,532–60,720 KiB through the measured cells and did not grow
during a cell. The coordinator accepted the timed cells with this
premeasurement increase recorded as a deviation. This does not show
swap-free setup or establish a maximum allocation ceiling. Benchy used
separate Linux calls for each depth; these are not slow-context-creep
results.

## arete-depth

Arete used q8_0, xhigh and no MTP. The model loaded at `-c 65536`, its
depth cap. The child arguments set `--n-gpu-layers 999` and `--fit off`
with no CPU-MoE or tensor-placement override. The warmup returned
`reasoning_content`. The log has no explicit layer-count line.
Resolved arguments and GPU samples are in
`results/arete-depth-c65536-resolved.json` and
`results/arete-depth-c65536-gpu-allocation.log`.

The required 64,512-token benchy cell passed at 20.07 tok/s. Other
depths also passed: 4K at 27.60 tok/s, 24K at 24.49 tok/s and 32K at
23.40 tok/s. Their prefill readings were 886.13, 823.36, 795.26 and
701.17 tok/s at 4K, 24K, 32K and 64,512. The deepest clean cell was
64,512. Its speed was above 8 tok/s. The largest serving context was
65,536, at the model's run cap. The harness window is 61,440 after
rounding down to 4,096.

The GPU used 15,761 MiB after the model loaded. It reached 15,771 MiB
during cells, with 168 MiB free. Swap used stayed near 60,240 KiB and
did not grow during the cells. The model ran at xhigh. MTP stayed off.
Depths above 65,536 were outside the model cap.
The run router is PID 440756, its child is PID 440825 and socat is PID
440757. Keep this model loaded for arete-tool-smoke.

## Derived values

| model | KV | serving context | clean depth | harness window | source |
|---|---|---|---|---|---|
| Arete | q8_0 | 65536 | 64512 | 61440 | `arete-depth` |
| S5-nano | q8_0 | 262144 | 261120 | 258048 | `s5-depth` |

## S5 coordinator decision

Use q8_0 KV. The timed cells are accepted with the pre-cell swap
increase recorded as a deviation. The full decision is in
[results/s5-kv-decision.md](results/s5-kv-decision.md).
The depth block must set the final serving context and harness window.
The new pending site row and pi id are `s5-nano-q8`. The initial
32768-token harness entry comes from the short test, not a full depth
ceiling. The run's newer depth result must replace it.

## Arete coordinator decision

Use q8_0 for Arete depth and later baseline blocks. The timed cells
are accepted with the premeasurement swap increase recorded as a
deviation. They showed no swap growth. This does not prove swap-free
setup or a maximum allocation ceiling.

The pending site row and pi id are `arete-27b-q3km`. The isolated
entry sends `enable_thinking` and `reasoning_effort` through the chat
template. This run uses xhigh and MTP stays off. The entry has no
`maxTokens` or `reserveTokens`. Its provisional window is 32,768; the
measured 61,440-token window applies to the tool smoke and full task.

## arete-tool-smoke

The smoke passed. It used pi 1.5.0, xhigh, site id `arete-27b-q3km`,
window 61,440 and keep budget 8,192. The run used the entry from
origin/master commit
`6bd14cd19d590b47d72ed2640c4075f479a95371`. The generated config
sent `enable_thinking` and `reasoning_effort` through the chat template.
It set no `maxTokens` or `reserveTokens`.

`SMOKE-MENDEL model=arete-27b-q3km level=xhigh task=xtend window=61440 pi=1.5.0 calls=14 distinct=14 longest_run=1 loop=ok:1.00 compactions=0 splits=0 peak=14621 commits=1 clean=yes end=stop wall_s=122 verdict=pass`

The smoke is unscored. It permits full simulator(mendel) work after
the EvalPlus gate. The model stayed loaded. The watcher stopped after
the smoke. The smoke copied the owner's auth and model-store files into
its run-local config. I removed both files from the run evidence after
the smoke. The generated models and settings files remain.

## s5-depth

S5-nano used q8_0, high Think mode and no MTP. The server loaded at
`-c 262144`, the identity table's depth cap. The resolved child
arguments set `--n-gpu-layers 999` and `--fit off`, with no CPU-MoE or
tensor-placement override. They used q8_0 K and V caches and an 8192
reasoning budget. The warmup passed. GPU allocation was 11,111 MiB
after load and 11,117 MiB during cells, with 4,822 MiB free.

| depth | prefill | decode |
|---:|---:|---:|
| 4096 | 6124.64 tok/s | 77.37 tok/s |
| 24576 | 5363.69 tok/s | 69.00 tok/s |
| 32768 | 5042.75 tok/s | 66.01 tok/s |
| 65536 | 4062.74 tok/s | 56.76 tok/s |
| 131072 | 2919.71 tok/s | 44.29 tok/s |
| 196608 | 2276.98 tok/s | 36.16 tok/s |
| 245760 | 1952.74 tok/s | 31.76 tok/s |
| 261120 | 1870.13 tok/s | 30.59 tok/s |

Every cell passed. The deepest clean depth was 261120, which exceeds
the 8 tok/s floor. The measured serving context was 262144. The
harness window is 258048 after rounding down to 4096. This was the
planned depth cap, not the card's absolute allocation maximum.

Swap used was 63380 KiB before the model load. It did not grow during
any timed cell. It fell from 61272 KiB before the 245760 cell to 61252
KiB after it. This does not show swap-free setup or measure a maximum
swap ceiling. Benchy used separate Linux calls; this is not a
slow-context-creep measurement. Deviation: swap was in use before the
model load.

Raw speed cells, resolved arguments, GPU allocation, memory samples,
warmup and server log are in `results/`.

## s5-tool-smoke

The smoke used S5-nano q8_0 at high Think, with MTP off and serving
context 262144. The entry came from origin/master commit
`ad3d1f750d9f7b91e982884985b24829230db81e`. The generated pi config
used window 258048 and the pi default keep value of 20000. It set no
`maxTokens` or `reserveTokens`. `gh auth status` passed. The watcher
used the server log and the live session file. The model stayed loaded
for the next S5 block.

Started 2026-11-09 02:59:03 UTC. Ended 03:01:04 UTC.

`SMOKE-MENDEL model=s5-nano-q8 level=high task=xtend window=258048 pi=1.5.0 calls=40 distinct=39 longest_run=1 loop=ok:0.92 compactions=0 splits=0 peak=24357 commits=0 clean=no end=stop wall_s=121 verdict=fail`

The fixture started with one commit. It had no new commit and three
modified files at the end. The session log shows the model used the
outer `run33` Git directory for its add and commit commands. It made
local commit `4d74f4d`, which added the fixture files to the run
branch. It then claimed the work was committed. The fixture remained
dirty. I reset the unpushed local commit to the pushed S5-depth commit
and kept the changed fixture files as smoke evidence. I removed the
copied `auth.json` and `models-store.json` files before saving the
config. The diagnostic, fixture, session, loop, config, stdout and
watcher memory files are in `results/s5-tool-smoke/`.

The smoke failed its commit and clean-tree gates. The loop check passed.
Skip S5 full simulator(mendel) blocks. Continue with S5 thinking quality.
Deviation: the model directed Git to the outer run branch; I removed
the local commit before pushing this block.

The coordinator retained the failed unscored gate. See
[the session review](results/s5-tool-smoke-review.md). S5's full
thinking quality test continues. Its full simulator(mendel) rows stay
skipped, and the site records the agent task as not run.

## s5-quality-think

Started 2026-11-09 03:09:26 UTC. The run uses the loaded S5-nano q8_0
server at `-c 262144`, high Think, reasoning budget 8192 and output
budget 16384. It uses no calibration. It uses the exact chat-template
body `{"chat_template_kwargs":{"enable_thinking":true}}`.

Ended 2026-11-09 05:05:41 UTC. EvalPlus completed all 164 problems.
Base pass@1 was 0.811. Plus pass@1 was 0.726. The completed samples
had 0 empty answers and 26 forced answers. The active wall was 116.3
minutes. The watcher saw no server failure. The model met the base
score threshold. S5 full simulator(mendel) remains skipped because
the tool smoke failed its commit and clean-tree gates. Raw samples,
finish records, evaluator output and watcher memory are in
`results/s5-quality-think/` and
`results/s5-quality-think-watch-memory.log`.

Coordinator correction, 2026-11-09: the block report said zero forced
answers. The fixed-message count command found 26 in `finish.jsonl`.
The evaluator confirms 133 base passes and 119 plus passes out of 164.
The scores and base gate do not change. No samples are regenerated.

Correction for the prior quality record: the first count used the wrong
message and reported 0 forced. The fixed command is
`python3 benchmarks/thinking-budget.py count hardware/arrietty/benchmarks/bench33/results/s5-quality-think --message 'Thinking budget reached. Give the final answer now.'`.
It reports 164 answers, 26 forced and 0 empty. The scores do not change.

## s5-quality-instruct

The corrected thinking count above is recorded at this block boundary.
Started 2026-11-09 05:12 UTC. Use S5-nano q8_0 with thinking off and
output budget 16384. The run uses the measured context 262144. It uses
no calibration. The request sets
`{"chat_template_kwargs":{"enable_thinking":false}}`.

I updated the active preset and reloaded the model through the router.
The run-owned router process stayed up. Its PID did not change. The
resolved child args set `--n-gpu-layers 999` and `--fit off`. They have
no CPU-MoE or tensor-placement override. They have no reasoning-budget
flag. The chat template sets `enable_thinking` false. The model loaded
and completed a real warmup. The response returned `ready` without a
reasoning field. GPU memory was 11111 MiB used and 4828 MiB free after
load. The watcher is active. Raw response, resolved args, server log
and watcher memory are in `results/`.

Ended 2026-11-09 05:38:27 UTC. EvalPlus completed all 164 problems.
Base pass@1 was 0.720. Plus pass@1 was 0.634. The completed samples
had 0 empty and 0 forced answers. The active wall was 25.5 minutes.
The fixed count command was
`python3 benchmarks/thinking-budget.py count hardware/arrietty/benchmarks/bench33/results/s5-quality-instruct --message 'Thinking budget reached. Give the final answer now.'`.
The run used no reasoning budget. This off score does not qualify the
thinking-on agent row. S5 simulator(mendel) remains skipped because
the tool smoke failed its commit and clean-tree gates. Samples,
finish records, evaluation output, resolved args, warmup, server log
and watcher memory are in `results/s5-quality-instruct*`.

## arete-quality-xhigh

Started 2026-11-09 05:42 UTC. Use Arete Q3_K_M with q8_0 K/V, xhigh,
serving context 65536, reasoning budget 8192 and output budget 16384.
The request sets
`{"chat_template_kwargs":{"enable_thinking":true,"reasoning_effort":"xhigh"}}`.
Use no calibration. I updated the active preset and reloaded the model
through the router. The run-owned router PID did not change. The
resolved child args set `--n-gpu-layers 999` and `--fit off`, with no
CPU-MoE or tensor-placement override. The model loaded and completed a
real warmup with `reasoning_content`. GPU memory was 15761 MiB used and
178 MiB free after load. The measured 65536 context is this run's
planned cap, not the card's absolute allocation maximum. The watcher
is active. Warmup, resolved args, server log and watcher memory are in
`results/`.


Ended 2026-11-09 09:07:05 UTC. EvalPlus completed all 164 problems.
Base pass@1 was 0.976. Plus pass@1 was 0.951. The completed samples
had 0 empty and 7 forced answers. The active wall was 204.1 minutes.
The fixed count command was
`python3 benchmarks/thinking-budget.py count hardware/arrietty/benchmarks/bench33/results/arete-quality-xhigh --message 'Thinking budget reached. Give the final answer now.'`.
The model met the base score threshold. Raw and sanitized samples,
finish records, evaluator output and code generation log are in
`results/arete-quality-xhigh/`. Watcher memory is in
`results/arete-quality-xhigh-watch-memory.log`.


## s5-bf16-f16-depth

Started 2026-11-09 09:17 UTC. Ended 09:47 UTC. I fetched the pinned
`S5-nano-BF16.gguf` file from revision
`5fd041274829d60aeeba1e2edc4aabb621a432e4`. It is 8,665,620,032
bytes with SHA-256
`565c6441c8c5297500f0bfc5d0cf14053b6e80e90976a5bd6586b56715cd8f1f`.
It uses the official llama.cpp b12110 build, high Think, f16 K/V and
no MTP or vision. The router PID stayed up. I reloaded its run-owned
preset through `/models?reload=1`; it served alias `s5-nano-bf16-f16`
from the BF16 file. Warmup returned `reasoning_content`.

The resolved child args set `--n-gpu-layers 999` and `--fit off`.
They have no CPU-MoE or tensor-placement override. A real completion
passed. The GPU reached 15,870 MiB used. The separate BF16 server log
has no explicit layer-count line. Record operational offload evidence;
do not infer a layer count from these observations.

| allocation | probe depth | decode | result |
|---:|---:|---:|---|
| 131072 | 130048 | 30.55 tok/s | pass |
| 163840 | 162816 | 28.89 tok/s | pass |
| 196608 | 195584 | 26.87 tok/s | pass |
| 204800 | 203776 | 26.41 tok/s | pass |
| 212992 | — | — | OOM in 282.02 MiB compute-buffer allocation |
| 229376 | — | — | OOM allocating a 7168 MiB KV buffer |
| 262144 | — | — | OOM allocating an 8192 MiB KV buffer |

The largest tested passing allocation is 204800. The depth curve at
that allocation passed at 4096, 24576, 32768, 65536, 131072 and 203776.
Decode speed fell from 45.68 to 26.41 tok/s. The deepest clean depth is
203776. The measured window is 200704, rounded down to 4096. This is
the trial's tested allocation bound, not the card's absolute maximum.

Swap use was 598 MiB before model load and 812 MiB after load, an
increase of 214 MiB. This is a setup deviation. Swap did not grow during
a timed cell; it fell by 1–10 MiB in the allocation probes and was flat
or fell across the depth curve. This does not establish swap-free setup
or a maximum swap ceiling. Host memory stayed available; GPU peak use
was 15870 MiB. The run used separate Linux benchy calls at two
repetitions with a five-second pause. This is not a
slow-context-creep-tool result.

The q8_0/q8_0 baseline used `c=262144`, window 258048 and decoded
66.01 tok/s at 32768. BF16/f16 used `c=204800`, window 200704 and
decoded 41.35 tok/s at 32768. Both weights and KV precision changed,
so this comparison does not assign the speed difference to either one.
The pinned file, load attempts, resolved args, warmups, per-cell speed
and memory samples, and router output are in `results/`.


## s5-bf16-f16-eval-smoke

Started 2026-11-09 09:56 UTC. Ended 10:00 UTC. The smoke used the
loaded BF16/f16 server at `c=204800`, high Think and the measured
200704 window. It used the fixed four-problem set, temperature 0,
server reasoning budget 8192 and output budget 16384. It used no
calibration. The request set `enable_thinking` true. The watcher saw
no server failure.

`SMOKE	label=s5-bf16-f16-eval-smoke	problems=4	passed=4	empty=0	completion_tokens=10335	max_tokens=16384	wall_s=249.3`

HumanEval/53, /45, /34 and /129 passed. All four answers were
nonempty. The Q8_0/q8_0 baseline smoke passed 3/4 with 0 empty answers,
so this config reads better on this unscored subset. This is not a
quality score. The samples, evaluator output, stdout and watcher memory
are in `results/s5-bf16-f16-eval-smoke/` and matching result files.
The BF16 server log is in `results/server-s5-bf16-f16.log`.


## s5-bf16-f16-tool-smoke

Started 2026-11-09 10:05 UTC. Ended 10:10 UTC. The smoke kept the
BF16/f16 server loaded at `c=204800`. The isolated pi config used alias
`s5-nano-bf16-f16`, actual BF16 file
`S5-nano-BF16.gguf`, measured context window 200704 and pi's default
keepRecentTokens value 20000. It set no `maxTokens` or `reserveTokens`.
It used the existing S5 high-thinking map, a fresh `xtend` fixture and
the 1500-second cap. `gh auth status` passed before launch. The watcher
read the active session JSONL and the router log.

`SMOKE-MENDEL model=s5-nano-bf16-f16 level=high task=xtend window=200704 pi=1.5.0 calls=57 distinct=45 longest_run=1 loop=ok:0.38 compactions=0 splits=0 peak=31850 commits=n/a clean=n/a end=stop wall_s=308 verdict=fail`

The run failed the fixture commit and clean-tree gate. The session shows
the model changed to the outer run33 worktree, removed the fixture's
`.git` directory and ran Git commands against the outer worktree. It
then made local commit `17aa1b31ee89ec82a40946576c386d02107f68e6`,
which added three fixture files to run33. I reset that unpushed commit
to the pushed `e2f92c36` commit. The fixture files and session remain
in this run's results. The session does not support a claim about
inherited Git variables. I added no rescue prompt and did not rerun.
The copied `auth.json` and `models-store.json` files are removed from
the evidence. The earlier S5 Q8_0 smoke also failed its commit and
clean-tree gate; this smoke gives no passing gate to compare.

The session, fixture, generated pi models and settings, loop report,
stdout, watcher memory and router evidence are in
`results/s5-bf16-f16-tool-smoke/` and matching result files. The
BF16/f16 depth and smoke blocks ended without a full EvalPlus or
simulator(mendel) row. The owner later requested the full EvalPlus run
below. No BF16/f16 simulator(mendel) row was run.

## Arete simulator rows deferred

On 2026-11-09, the owner stopped Arete simulator(mendel) work and deferred the guided and blind rows to a future run. Mark both rows NOT STARTED. Do not report a partial result or score.

The owner directed cleanup of the aborted guided run. We removed its generated pi config and run files from `~/.local/share/mendel-benchmark/`, plus its task worktree and two setup worktrees with their local branches. No session, events, stdout, meta, watcher output or generated config remains for this row. We kept the completed Arete depth, tool-smoke and xhigh EvalPlus evidence, and all S5 evidence.

The run router and Arete child stopped. No llama-server, Mendel Daemon or run watcher remains. Port 8080 is closed. The first post-stop sample showed 858 MiB used and 15,081 MiB free. The run33 heartbeat is disabled.

## Cleanup follow-up

On 2026-11-09, we found the run-owned `socat` forwarder on port 8081 (PID 447875). We stopped it. Its signal record is in `results/s5-depth-c262144-socat.log`. Both ports are closed. The final VRAM sample showed 782 MiB used and 15,157 MiB free. No test restarted.

## S5 BF16/f16 full EvalPlus

The owner requested a full thinking-on EvalPlus run at `c=65536`.
This is the selected allocation, not a new depth ceiling. The run used
official llama.cpp v0.9.0 b12110, commit `cd959bae9`.

The resolved preset used alias `s5-nano-bf16-f16` and the pinned
`S5-nano-BF16.gguf` file. The file is 8,665,620,032 bytes. Its
SHA-256 is `565c6441c8c5297500f0bfc5d0cf14053b6e80e90976a5bd6586b56715cd8f1f`.
The preset set f16 K/V, one slot, high Think and
`enable_thinking=true`. It set 8192 reasoning tokens with the fixed
message and 16384 output tokens. It set `n-gpu-layers=999` and
`fit=off`. It had no CPU-MoE or tensor placement override.

The server log has no explicit layer-count line. The resolved arguments
and real completion support operational full-offload evidence only.
They do not support an N/N claim or prove placement from VRAM alone.
The initial model allocation was 10,456 MiB. Total, used and free VRAM
were 16,311, 11,529 and 4,410 MiB.

The first active part started at 11:14:18 UTC. T3 transport recovery
stopped the runner, watcher and router after 14 answers. The exact
count command found 14 answers, 2 forced and 0 empty. The last server
log update was at 11:27:08 UTC. No run process or listener remained by
the 11:28:01 UTC check. I kept the completed samples and codegen log.

The second part started at 11:31:54 UTC. It resumed from those samples
and added 4 answers. T3 stopped the services while HumanEval/18 was
still generating. The last server log update was at 11:35:15 UTC.

The third part started at 11:50:27 UTC. I ran the router, forwarder,
watcher and evaluator as transient user services. A real warmup
completed with `Ready`, `finish_reason=stop`, reasoning content and
56 total tokens. EvalPlus resumed from the existing 18 task IDs.
It finished and evaluated all 164 problems at 15:15:28 UTC.

Base pass@1 was 0.841. Plus pass@1 was 0.774. The exact count command
found 31 forced answers and 0 empty answers. Forced IDs are in
`results/s5-bf16-f16-quality-think-64k-thinking-budget-count.txt`.

The first part lasted 12m50s to 13m43s. Its end falls between the last
log update and the no-process check. The second part lasted 3m21s. The
third part lasted 205m01s. Active wall time was 221.2–222.1 minutes,
including evaluation. The run did not count the gaps between parts.

The q8_0/q8_0 high-thinking baseline scored 0.811 base and 0.726 plus.
It had 26 forced and 0 empty answers. This run changed both weights
and KV type. The scores do not isolate either change.

I stopped the router, forwarder, router logger and watcher. Both ports
are closed. All run services are inactive. VRAM returned to 1,139 MiB
used and 14,800 MiB free. The run33 heartbeat is disabled. No further
task started.

## Port-migration pause

The owner requested a migration to port 8888. The full EvalPlus process
had already completed at 15:15:28 UTC. At the 15:23:16 UTC check, the
runner, watcher, router and forwarder were inactive. No run listener
remained on ports 8080 or 8081, so this request stopped no active
process. The completed sample file has 164 unique IDs, from
HumanEval/0 through HumanEval/163, with no missing or duplicate IDs.
I saved the ID list in `results/s5-bf16-f16-quality-think-64k-completed-task-ids.txt`.

I preserved all samples, finish records and raw evidence. I did not
restart generation or change shared scripts or client defaults. This
block records the port-migration pause on `run33`. I will wait for the
owner's resume instruction.

The coordinator migrated current router, pi, EvalPlus, smoke, watcher
and preflight defaults to port 8888. All 164 problems had already
completed, so there was no generation to resume. Historical evidence
keeps its original endpoints. The official idle router was restored
on 8888 and passed its health check. No model or new test was loaded.

## S5 text-only MTP performance continuation

The active runner checkout is `/home/irae/.t3/worktrees/choose-a-local-llm/t3-13bc8e56` on branch `t3/s5-mtp-performance`. The branch started at `be36dd59a76a39e9075a5d51ece21331c3bfa3b6`. This runner does not use the old `run33` worktree. The copied runbook matches the coordinator source hash `16a1df849d4b44c35317290fccfd3283ceeb8595681e70197470d49f69fa7e68`.

The current scope is the Q8_0/f16 MTP performance task, then the BF16/f16 MTP performance task. No quality, simulator(mendel), smoke, vision load, Arete, or older task runs in this continuation.

At 2026-11-09 14:02 local time, arrietty was `arrietty` with an RTX 5060 Ti. The idle official router was running with no model loaded. It stopped cleanly before this task. After it stopped, the GPU used 1,139 MiB and had 14,800 MiB free; temperature was 30 C and power was 3.90 W. Host memory had 13,579 MiB available. Swap used was 1,954 MiB. These are measured values; no GUI app or host setting changed.

Preflight is in `results/s5-mtp-preflight.log`. Linux-only interpretation: the missing macOS machine file, wired-limit check, login-item action and macOS memory probe do not apply on arrietty. The direct Linux memory, swap and GPU readings above are the start sample. GPU-free, port refusal, reboot, GitHub auth and pi version checks passed.

The pinned Q8_0 file is `/home/irae/.cache/huggingface/hub/models--maritaca-ai--S5-nano-GGUF/snapshots/5fd041274829d60aeeba1e2edc4aabb621a432e4/S5-nano-Q8_0.gguf`, 4,610,580,032 bytes, SHA-256 `f82c0edcb4fa74dc2db7246ef0532f23288943f9f88ec4066b77b1cba307354f`. The pinned BF16 file is in the same snapshot, 8,665,620,032 bytes, SHA-256 `565c6441c8c5297500f0bfc5d0cf14053b6e80e90976a5bd6586b56715cd8f1f`. Both are at repo revision `5fd041274829d60aeeba1e2edc4aabb621a432e4`. The S5 tokenizer snapshot is `/home/irae/.cache/huggingface/hub/models--maritaca-ai--S5-nano/snapshots/ae981dc208f3bba2939c4cf242fab3e9a83e4938`. The corpus service is run-owned, transient and serves the pinned file whose SHA-256 is `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`; its PID is 911503 on port 8089.

The official runtime is `/home/irae/.local/share/mise/installs/llama-cpp/b12110/llama-server`, v0.9.0, build b12110, commit `cd959bae99ff4bed22bef2604f45241c09bbb8c8`; it exposes CUDA0. `llama-benchy` is 0.4.0, `hf` is 1.31.0 and pi is 1.5.0. The speed cells use Linux llama-benchy, two repetitions and five-second post-run pauses. They are not slow-context-creep measurements.

### Q8_0/f16 MTP setup and verification

The n-max 3 preset loaded the pinned Q8_0 file at context 131072. A real high-Think completion returned 22 predicted tokens, 27 drafted tokens and 12 accepted tokens: 44.44% acceptance over 27 drafted tokens. The server log confirms it created an MTP draft context. The preset requested one slot, f16 K/V, flash attention, `n-gpu-layers=999`, `fit=off`, no projector and no MTP drafter download. This build does not print an N/N layer count. Treat this as operational full-offload evidence only.

The router's `/metrics` endpoint requires `?model=<alias>`; a request without the model returned HTTP 400. With the alias, the official metrics endpoint reports per-model speculative draft and acceptance counters. Every tuning and curve cell records before/after metrics, the matching server-log slice, the benchy output, GPU memory, available host memory and swap.

The Q8 MTP3 model used 10886 MiB VRAM after load and 10886 MiB during its warmup. Free VRAM was 5053 MiB. Host available memory was 13815 MiB. Swap rose from 1954 MiB before load to 2956 MiB after load and warmup. It remained at 2954 MiB after the model stopped. This happened before timed cells and is recorded as a premeasurement deviation. The machine had 13462 MiB available before the load. No timed result exists yet.

The no-drafter control loaded at the same context. Its real warmup returned reasoning content and no draft counters. VRAM used was 9916 MiB after load, with 6023 MiB free. Host available memory was 13835 MiB and swap used was 2953 MiB. Its preset keeps the Q8_0 weights, f16 K/V, high Think, one slot, full-offload request and no projector. The 4096-token tuning cell is running as a transient user service.

The no-drafter 4096-token tuning cell completed at allocation 131072. Benchy measured 6194.53 prefill tok/s and 77.73 decode tok/s across two repetitions. The two server timing rows generated 512 target tokens total. Drafted and accepted counts were both zero. VRAM was 9916–9920 MiB; available host memory was 13831–13782 MiB; swap stayed at 2952 MiB. The result, client output, server timing slice, metrics and memory samples are in `results/s5-q8-f16-tune-n0-4096*`.

The no-drafter tuning readings passed at allocation 131072. Benchy measured 5179.03 prefill / 66.03 decode tok/s at depth 32768, and 3038.19 prefill / 43.47 decode tok/s at depth 130048. Each result used two measured repetitions of 256 target tokens. Drafted and accepted counts were zero. Swap stayed at 2952 MiB through 32768 and fell from 2952 to 2950 MiB at 130048. VRAM stayed at 9920 MiB. Available host memory was 13799–13722 MiB at 32768 and 13731–13599 MiB at 130048. Logs, metrics and outputs are in the matching `results/s5-q8-f16-tune-n0-*` files.

### Q8 MTP1 swap stop

The MTP1 4096-token benchy call completed at allocation 131072 and returned 101.24 decode tok/s with two 256-token measured repetitions. Their server records show 206 accepted of 302 drafted tokens (68.21%). The sample is excluded from comparisons because `free -m` showed swap used rise from 2949 to 2952 MiB during the cell. The 32768-token cell was stopped before it completed. Its partial server log is retained; it has no result row.

The first transient cell wrapper used unsupported `swapon --show --output=USED`. The command failed and the wrapper's numeric comparison failed open. The error is in the transient unit journal. Both the benchmark service and MTP1 router are stopped. GPU use returned to 1141 MiB. The current `/proc/swaps` sample is 3023188 KiB. Later cell wrappers will record exact `/proc/swaps` values before and after each cell and stop if either value is missing or swap grows.

The MTP1 retry used exact swap readings from `/proc/swaps`. Its 4096-token cell measured 5569.78 prefill / 103.92 decode tok/s. The two measured repetitions used 512 generated target tokens; their server records provide the per-request draft counts. Swap fell from 3022472 to 3022408 KiB. This cell is clean.

The retry 32768-token cell measured 4670.66 prefill / 86.15 decode tok/s, but swap rose from 3022408 to 3022524 KiB and host available memory fell from 13488 to 10525 MiB during the cell. The cell is retained as a raw, invalid reading. The exact swap guard exited 42 and stopped before the 130048 arm. The MTP1 router is now stopped. After unload, GPU use returned to 1141 MiB, available host memory was 12497 MiB and swap was 2992572 KiB. The exact swap-stability samples are in `results/s5-q8-swap-stability.log`.

The clean MTP1 retry at depth 4096 measured 5569.78 prefill / 103.92 decode tok/s. Its two measured requests accepted 214 of 295 drafted tokens (72.54%). At depth 32768, it measured 4681.12 prefill / 89.04 decode tok/s; the two measured requests accepted 212 of 296 drafted tokens (71.62%). Both cells used allocation 131072 and two 256-token measured repetitions. Swap fell by 64 KiB and 144 KiB, respectively. The first 32768 attempt remains invalid and is not used.

The clean MTP1 retry at depth 130048 measured 2709.12 prefill / 59.87 decode tok/s. The two measured requests accepted 214 of 295 drafted tokens (72.54%). Swap fell from 2991724 to 2944976 KiB. VRAM used was 10784 MiB. Available host memory was 13310–13358 MiB. MTP1 is faster than the no-drafter control at all three tuning depths, so the upward comparison continues with n-max 2.

The MTP2 warmup confirmed active drafting: 11 of 16 draft tokens were accepted. The real-text 4096-token tuning cell measured 5559.65 prefill / 101.79 decode tok/s. Its two measured requests accepted 245 of 528 drafted tokens (46.40%). Allocation was 131072. VRAM used was 10828–10834 MiB. Available host memory was 13603–13420 MiB. Swap fell from 2944860 to 2944752 KiB.

The MTP2 32768-token tuning cell measured 4665.73 prefill / 89.92 decode tok/s. Its two measured requests accepted 251 of 513 drafted tokens (48.93%). Allocation was 131072. VRAM used was 10828–10834 MiB, host available memory was 13603–13379 MiB, and swap fell from 2944752 to 2944696 KiB.

The MTP2 130048-token tuning cell measured 2698.55 prefill / 61.07 decode tok/s. Its two measured requests accepted 262 of 504 drafted tokens (51.98%). Allocation was 131072. VRAM use stayed at 10834 MiB, host available memory was 13377–13298 MiB, and swap fell from 2944696 to 2944384 KiB. MTP2 is faster than MTP1 at the middle and deep readings, and slower at the shallow reading. The comparison proceeds to n-max 3.

The MTP3 4096-token tuning cell measured 5554.38 prefill / 96.83 decode tok/s. Its two measured requests accepted 260 of 743 drafted tokens (34.99%). Allocation was 131072. VRAM used was 10878–10884 MiB, host available memory was 13431–13270 MiB, and swap fell from 2944072 to 2943944 KiB. MTP3 is slower than MTP1 and MTP2 at the shallow depth.

The MTP3 32768-token tuning cell measured 4668.54 prefill / 91.73 decode tok/s. Its two measured requests accepted 284 of 671 drafted tokens (42.32%). Allocation was 131072. VRAM use stayed at 10884 MiB, host available memory was 13412–13379 MiB, and swap fell from 2943944 to 2943888 KiB. MTP3 is faster than MTP2 at the middle depth and slower at the shallow depth.

Q8 MTP tuning finished at the three required depths. The n-max 1 arm leads at 4096 tokens (103.92 decode tok/s), n-max 3 leads at 32768 (91.73 tok/s), and n-max 2 leads at 130048 (61.07 tok/s). Since the middle and deep readings cross, the n-max 3 comparison completed; n-max 1 is the shallow winner and n-max 2 the deep winner. The no-drafter control was slower at all tuning depths.

The no-drafter Q8 control passed c=262144 with a real d=261120 cell at 29.73 decode tok/s. VRAM use was 14144 MiB and free was 1795 MiB. Host available memory was 14360 MiB before and 13435 MiB after. Swap fell from 2868388 to 2867664 KiB. It is a clean allocation ceiling.

Q8 MTP2 passed c=262144 with a real d=261120 cell at 43.91 decode tok/s. The measured requests 287 and 544 accepted 266 of 484 drafted tokens (54.96%); request 33 is the earlier corpus check and request 8 is the short warmup. VRAM use was 15698 MiB and free was 241 MiB. Host available memory was 14367 MiB before and 12960 MiB after. Swap fell from 2867604 to 2865304 KiB. It is a clean allocation ceiling. The cell output file's server slice was empty due an offset-selection mistake; the complete router log retains all request timings and acceptance records.

Q8 MTP1 passed c=262144 with a real d=261120 cell at 37.98 decode tok/s. Its measured requests 1989 and 2153 accepted 205 of 305 drafted tokens (67.21%). VRAM use was 15648 MiB and free was 291 MiB. Host available memory was 14476 MiB before and 12908 MiB after. Swap fell from 2863432 to 2862160 KiB. The complete server log retains the draft counters. VRAM, host memory and exact swap readings are in `results/s5-q8-f16-mtp1-c262144-d261120-memory.log`. It is clean. Full curves are now running as transient user services, with each cell independently checking swap growth and preserving its output.

The Q8 MTP1 full curve stopped at depth 147456 because exact swap grew by 820 KiB (2856684 to 2857504 KiB). That timed cell measured 54.86 decode tok/s and is retained as invalid. The previous clean cell was depth 131072, at 57.43 decode tok/s; its swap fell from 2856936 to 2856684 KiB. The allocation ceiling remains c=262144 from its separate passing real cell. The script's per-cell server slice offset fallback selected the wrong source log; full per-arm server logs retain the requests, and the slice source will be corrected for remaining curves.

The Q8 MTP2 curve passed through the 261120-token cell. Its clean depth was 261120 and its derived 4096-token harness window is 258048. The separate no-draft curve also passed depth 261120 at 29.73 tok/s; its derived window is 258048. Exact per-cell memory and swap records are in `results/`.

The MTP3 deep tuning sample contains two requests: 140/343 and 140/344. Together they accepted 280 of 687 drafted tokens (40.8%, n=2). This replaces the first one-request summary.

Q8 results are in `results.md`. The full MTP1 and MTP2 per-cell server-output slices were rebuilt from the retained router logs by matching prompt depth. The MTP2 ceiling router log was overwritten when the curve service restarted that preset. Its benchy output and before/after metrics remain: the counters show 769 drafted and 418 accepted tokens over the short warmup and three full requests. The two measured requests accepted 266/484 (55.0%). No-draft passed at c=262144 with 1795 MiB free; the 641 MiB projector file could fit by file size alone. MTP1 and MTP2 left 291 MiB and 241 MiB free and could not fit that file. Image workspace and runtime overhead remain unknown; no vision files were loaded.

The Q8 continuation is complete. The transient curve services and their router readers have exited. The run-owned corpus service remains available for the BF16 continuation. No heartbeat was started.
