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

## Derived values

| model | KV | serving context | clean depth | harness window | source |
|---|---|---|---|---|---|
| Arete | pending | pending | pending | pending | |
| S5-nano | pending | pending | pending | pending | |
