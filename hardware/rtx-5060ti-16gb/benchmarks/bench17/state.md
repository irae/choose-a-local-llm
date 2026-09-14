# Run 17 — state

The run's log. The runner writes the medium form of every block here
at block close (`docs/methodology/status-lines.md`), deviations as
they happen, and a handing-over section at the end of every session.

## Machine

- Linux desktop, Arch, kernel 7.2.3. GeForce RTX 5060 Ti, 16311 MiB,
  compute capability 12.0, driver 610.57.04, CUDA 13.3 capable.
  12 CPU threads, 31 GB RAM, 111 GB free on disk at planning time.
- Nothing installed for the run at planning time: `machine-setup`
  records every version and every file hash below.

## Values

Written by the blocks, read by later blocks. One line per value, with
its source.

| value | number | source |
|---|--:|---|
| `vram_start_mb` | 838 | `machine-setup`, `nvidia-smi` |
| `llama_version` | - (binary not runnable, permission block) | `machine-setup` |
| `benchy_version` | 0.4.0 | `machine-setup` |
| `hf_version` | 1.31.0 | `machine-setup` |
| `gemma12_nvfp4_c` | - | - |
| `gemma12_nvfp4_clean` | - | - |
| `gemma12_q4kxl_c` | - | - |
| `gemma12_q4kxl_clean` | - | - |
| `qwen38_iq3s_f16_c` | - | - |
| `qwen38_iq3s_f16_clean` | - | - |
| `qwen38_iq3s_q8_c` | - | - |
| `qwen38_iq3s_q8_clean` | - | - |
| `qwen36_nvfp4_n_cpu_moe` | - | - |
| `qwen36_nvfp4_clean` | - | - |
| `gemma26_nvfp4_n_cpu_moe` | - | - |
| `gemma26_nvfp4_clean` | - | - |

## Files and revisions

| repo | file | revision | sha256 |
|---|---|---|---|
| `FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF` | `gemma-4-12b-it-nvfp4.gguf` | `207974a8455870a3a5d0b6854698f2a4f3c6347e` | `8f03a67ca9e7ed7cbf38527a5fa1cd806dba5272feffeb5c5f21865b6961dcad` |
| `unsloth/gemma-4-12b-it-GGUF` | `gemma-4-12b-it-UD-Q4_K_XL.gguf` | `fc034cfff751157913579611efad8462ac1be606` | `90fd944d227e9d9b68e7e2c7d5b57b79d4c66ed521b0919fbbd932cf834f6f8e` |
| `unsloth/Qwen3.8-27B-GGUF` | `Qwen3.8-27B-UD-IQ3_S.gguf` | `4ca720788d1e01f1bff70c033e0d0028fd02e502` | `d847e2c1e4aa276e4b7b8e9ad7628050e61e165d49ab995407bc36677a6f3864` |
| `michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF` | `Qwen3.6-35B-A3B-NVFP4-MTP-HQ.gguf` | `df112dd576e55b1daa1331a7831b64ec9c03dbae` | `777564174a7ccf01a2e9d171ac73206ec3da6b6f6b0124e71a9628ac19f61aa9` |
| `catlilface/Gemma-4-26B-A4B-NVFP4-GGUF` | `Gemma4-26b-NVFP4Q8.gguf` | `dc98839f4c28f571ac43fb91ab99357471eaff5c` | `62e1590ef5aeba9a2101508eb461083f1e050e97a68d61d86ba003c0a857a895` |

Tokenizers (benchy fetches on first use, ungated): `unsloth/gemma-4-12b-it`
(both Gemma-12B builds), `unsloth/Qwen3.8-27B`, `unsloth/Qwen3.6-35B-A3B`,
`unsloth/gemma-4-26B-A4B-it`.

`llama.cpp` binary: `keypaa/llamaup` release `v0.4.0` (tag `v0.4.0`), the
`sm120` `cuda12.8` archive. Downloaded to
`~/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/`, sha256
checked against the release's own `.sha256` file: pass. Not yet
executed; `llama_version` and the `--help` greps wait on the owner's
word (see deviation below).

`pi` config: `providers.llama` written into `~/.pi/agent/models.json`
with the five model entries. `pi --list-models | grep -E 'gemma-4|qwen3'`
shows all five aliases (`gemma-4-12b-nvfp4`, `gemma-4-12b-q4kxl`,
`gemma-4-26b-a4b-nvfp4`, `qwen3.6-35b-a3b-nvfp4`, `qwen3.8-27b-iq3s`)
with their planning `contextWindow` values. Pass.

Corpus server: `python3 -m http.server 8089 --bind 127.0.0.1` running
in the background over
`hardware/m1-max-32gb/research/run4/results`. `corpus-mendel-js.txt`
sha256 `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`,
matches. `curl` to `http://127.0.0.1:8089/corpus-mendel-js.txt` returns
200.

Directories: `~/.local/share/choose-a-local-llm`,
`~/.local/share/mendel-benchmark` created.

## Blocks

### machine-setup — running

Deviation (resolved): the session's own auto-mode permission classifier
refused to run the downloaded `llama-server` binary. The owner reset the
session's permission mode; the binary now executes.

Deviation (open, stop and ask): the binary fails to start,
`error while loading shared libraries: libnccl.so.2: cannot open shared
object file: No such file or directory`. `libcublas.so.12` and
`libcublasLt.so.12` were also missing but the archive ships the
unversioned `libcublas.so` / `libcublasLt.so` in the same `lib/`
directory, so a local symlink (`libcublas.so.12 -> libcublas.so`,
`libcublasLt.so.12 -> libcublasLt.so`) fixed those two. `libnccl.so.2`
has no local copy anywhere: not in the archive's `lib/`, not on the
system (`find / -iname libnccl*`, `pacman -Qs nccl` both empty). The
release's claim to bundle the CUDA runtime is incomplete for this file.
This machine has no sudo and no CUDA toolkit, so the runbook's own
download allowlist (the llama.cpp binary, `llama-benchy`, `hf`, the five
model files, the four tokenizers) does not cover fetching it. Candidate
answer: `pip download nvidia-nccl-cu12` (or `uv pip install
--target ... nvidia-nccl-cu12`), user-level, no sudo, to pull the .so
from the PyPI wheel and symlink it into the archive's `lib/`; NCCL is a
multi-GPU library and this card is the only GPU, so it is a load-time
dependency only, never exercised. Waiting on the coordinator.

## Handing over

Not started.
