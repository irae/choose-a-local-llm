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

## Derived values

| model | KV | serving context | clean depth | harness window | source |
|---|---|---|---|---|---|
| Arete | pending | pending | pending | pending | |
| S5-nano | pending | pending | pending | pending | |
