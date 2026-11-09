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
