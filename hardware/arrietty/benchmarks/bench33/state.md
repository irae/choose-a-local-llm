# Run 33 state

Planned 2026-11-08. Block records follow below.

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
less than 10%. The candidate is q8_0 under the method. The coordinator
must record the final KV choice.

Swap used was 0 MiB at machine start. It rose to 13,288 KiB before the
first timed S5 cell. It stayed at 13,288 KiB before and after every
timed cell. The coordinator accepted the throughput readings. This
does not show swap-free setup or establish a maximum memory ceiling.

The coordinator selected q8_0 for S5 depth. The site entry is
`s5-nano-q8`. Its provisional site window is 32,768 tokens. Use the
measured s5-depth window for the tool smoke and full task.

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
within 10% of f16. The coordinator decides the Arete cache for depth.

The first run router used PID 432837 with child 432912 and socat PID
432838. The f16 smoke reload used router PID 437251 with child 437298
and socat PID 437252. Both run routers stopped after their cells.

Swap used was 60,720 KiB before the first Arete speed cell. It stayed
near 60,532–60,720 KiB through the measured cells and did not grow
during a cell. This is a premeasurement increase, not a swap-free
setup or a maximum memory ceiling. Benchy used separate Linux calls
for each depth; these are not slow-context-creep results.

## Derived values

| model | KV | serving context | clean depth | harness window | source |
|---|---|---|---|---|---|
| Arete | q8_0 | 34816, short test only | 32768 | pending newer depth result | `arete-kv-feedback` |
| S5-nano | q8_0 | 34816, short test only | 32768 | pending newer depth result | `s5-kv-feedback` |

## S5 coordinator decision

Use q8_0 KV. The timed cells are accepted with the pre-cell swap
increase recorded as a deviation. The full decision is in
[results/s5-kv-decision.md](results/s5-kv-decision.md).
The depth block must set the final serving context and harness window.
The new pending site row and pi id are `s5-nano-q8`. The initial
32768-token harness entry comes from the short test, not a full depth
ceiling. The run's newer depth result must replace it.

## Arete coordinator decision

Use q8_0 KV for Arete depth and later baseline blocks. Both types
served the short test at `-c 34816`. At 32K q8_0 used about 920 MiB
less GPU memory. Its decode speed was within 10 percent of f16.
Both fixed smokes passed 4 of 4 problems with no empty answer.
This smoke is not a full quality score.

Accept the timed cells with the premeasurement swap increase as a
deviation. No measured cell showed swap growth. This does not show
swap-free setup or establish a maximum memory ceiling. The depth
block must measure its own ceiling and set the later harness window.

The pending site row and pi id are `arete-27b-q3km`. The initial
32768-token entry comes from the short test. The isolated generator
entry sends `enable_thinking` and `reasoning_effort` through the chat
template. This run uses xhigh. It sets keepRecentTokens to 8192 at
the provisional window and sets no maxTokens or reserveTokens.
Use the newer depth result for the tool smoke and full task.
