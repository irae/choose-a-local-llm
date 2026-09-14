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
| `llama_version` | 0.4.0-dev (build 10809, commit 5266f24da) | `machine-setup` |
| `benchy_version` | 0.4.0 | `machine-setup` |
| `hf_version` | 1.31.0 | `machine-setup` |
| `gemma12_nvfp4_c` | 262144 | `sweep-gemma12-nvfp4` |
| `gemma12_nvfp4_clean` | 261120 | `sweep-gemma12-nvfp4` |
| `gemma12_q4kxl_c` | 262144 | `sweep-gemma12-q4kxl` |
| `gemma12_q4kxl_clean` | 261120 | `sweep-gemma12-q4kxl` |
| `qwen38_iq3s_f16_c` | 53248 | `sweep-qwen38-iq3s` (stepped down from 61440 after a crash) |
| `qwen38_iq3s_f16_clean` | 52224 | `sweep-qwen38-iq3s` |
| `qwen38_iq3s_q8_c` | 65536 | `sweep-qwen38-iq3s` |
| `qwen38_iq3s_q8_clean` | 64512 | `sweep-qwen38-iq3s` |
| `qwen36_nvfp4_n_cpu_moe` | - | - |
| `qwen36_nvfp4_clean` | - | - |
| `gemma26_nvfp4_n_cpu_moe` | 7 | `sweep-gemma26-nvfp4` |
| `gemma26_nvfp4_clean` | 97280 | `sweep-gemma26-nvfp4` (no-drafter arm) |

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

### machine-setup

Deviation (resolved): the session's own auto-mode permission classifier
refused to run the downloaded `llama-server` binary. The owner reset the
session's permission mode; the binary now executes.

Deviation (resolved): the binary was missing three shared libraries the
release claims to bundle. `libcublas.so.12` / `libcublasLt.so.12`:
fixed with a local symlink to the archive's own unversioned
`libcublas.so` / `libcublasLt.so`, same `lib/` directory. `libnccl.so.2`:
not in the archive and not on the system at all. The owner installed
the Arch `nccl` package first (`sudo pacman -S nccl`, 2.31.2-1), but it
is built against CUDA 13 and needs `libcudart.so.13`, which conflicts
with the archive's own CUDA 12.8 `libcudart.so.12` (a cross-major
symlink was rejected as an ABI risk). Owner's word: "use uv". Fetched
`nvidia-nccl-cu12` (2.31.2, matches the system package's version, built
for CUDA 12) with `uv pip install --target`, copied its `libnccl.so.2`
into the archive's `lib/`. `llama-server --version` now runs:
`version: 0.4.0-dev (build 10809, commit 5266f24da), built with GNU
9.4.0`. `--list-devices` shows `CUDA0: NVIDIA GeForce RTX 5060 Ti
(15885 MiB, 15155 MiB free)`. `--help` lists `--fit`, `--fit-target`,
`--fit-ctx`, `--n-cpu-moe`, `--spec-draft-n-cpu-moe`; no `--nvfp4` flag,
expected since NVFP4 support reads from the GGUF quant type, not a CLI
switch. `llama_version` recorded below. `PATH`/`LD_LIBRARY_PATH` for
every session of this run:
`export PATH="$HOME/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/bin:$PATH"`,
`export LD_LIBRARY_PATH="$HOME/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/lib:$LD_LIBRARY_PATH"`.

### sweep-gemma12-nvfp4

`FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF` `gemma-4-12b-it-nvfp4.gguf`
rev `207974a`, f16 KV, no drafter, one slot, `-c 262144`. Started
05:13, closed 05:37.

| depth | tok/s | VRAM MB | MemAvailable |
|--:|--:|--:|--:|
| 4096 | 49.55 | 12355 | 22711 |
| 98304 | 41.57 | 12355 | 22738 |
| 261120 | 33.11 | 12630 | 22547 |

speed/mem headroom, ceiling 261120 @ 33.11 tok/s (well above the Mac's
9.2 tok/s at 245K on the k-quant). `gemma12_nvfp4_c` = 262144,
`gemma12_nvfp4_clean` = 261120.
Files: `results/benchy-gemma12-nvfp4-f16.md`,
`results/server-sweep-gemma12-nvfp4.log`,
`results/benchy-gemma12-nvfp4-f16-vm.log`.
Deviation: the first server start's `tee` failed (results dir did not
exist yet when the process launched), no data lost — server log
recreated on restart before any benchy request ran.

### sweep-gemma12-q4kxl

`unsloth/gemma-4-12b-it-GGUF` `gemma-4-12b-it-UD-Q4_K_XL.gguf` rev
`fc034cf`, f16 KV, no drafter, one slot, `-c 262144`. Started 05:47,
closed 06:23.

| depth | tok/s | VRAM MB | MemAvailable |
|--:|--:|--:|--:|
| 4096 | 47.39 | 13052 | 22785 |
| 98304 | 40.26 | 13052 | 22846 |
| 261120 | 32.18 | 13000 | 22635 |

speed/mem headroom, ceiling 261120 @ 32.18 tok/s. `gemma12_q4kxl_c` =
262144, `gemma12_q4kxl_clean` = 261120. The NVFP4 build reads faster
at every depth than this k-quant control (49.6 vs 47.4 at 4K, 33.1 vs
32.2 at 261K).
Files: `results/benchy-gemma12-q4kxl-f16.md`,
`results/server-sweep-gemma12-q4kxl.log`,
`results/benchy-gemma12-q4kxl-f16-vm.log`.
Deviation: none.

### sweep-qwen38-iq3s (f16 arm)

`unsloth/Qwen3.8-27B-GGUF` `Qwen3.8-27B-UD-IQ3_S.gguf` rev `4ca7207`,
f16 KV, no drafter, one slot. Ladder loads: 65536 fail, 32768 pass,
49152 pass, 57344 pass, 61440 pass (6 loads, cap reached), 63488 fail.
61440 then crashed on a real request (CUDA OOM at warmup); stepped
down to `-c 53248`, clean. Started 06:20, closed 06:42.

| depth | tok/s | VRAM MB | MemAvailable |
|--:|--:|--:|--:|
| 4096 | 29.96 | 15453 | 23836 |
| 24576 | 27.21 | 15453 | 23880 |
| 52224 | 24.34 | 15453 | 23830 |

speed/mem, ceiling 52224 @ 24.34 tok/s (vs Mac's 8.1 tok/s at 147K on
the same quant at f16 — much shallower window here, much faster per
token). `qwen38_iq3s_f16_c` = 53248, `qwen38_iq3s_f16_clean` = 52224.
Files: `results/benchy-qwen38-iq3s-f16.md`,
`results/server-sweep-qwen38-iq3s-f16.log`,
`results/benchy-qwen38-iq3s-f16-vm.log`.
Deviation: the 61440 load-pass was not a real pass — the model plus
compute buffers for an actual request need more headroom than the
bare load check shows. Retried at `-c` minus 8192 in the same block,
per the owner's 2026-09-13 retry rule; no data lost, the crashed run's
`-save-result` file was never written. Swap held flat at 604-638 MB.

### sweep-qwen38-iq3s (q8_0 arm)

`unsloth/Qwen3.8-27B-GGUF` `Qwen3.8-27B-UD-IQ3_S.gguf` rev `4ca7207`,
q8_0 KV, no drafter, one slot, `-c 65536`. Passed at load and at the
deep cell, no retry. Started 06:44, closed 06:56.

| depth | tok/s | VRAM MB | MemAvailable |
|--:|--:|--:|--:|
| 4096 | 29.36 | 14527 | 23950 |
| 24576 | 25.84 | 14527 | 23900 |
| 64512 | 20.92 | 14527 | 23890 |

speed/mem, ceiling 64512 @ 20.92 tok/s. `qwen38_iq3s_q8_c` = 65536,
`qwen38_iq3s_q8_clean` = 64512. Wider window than the f16 arm (65536
vs 53248) at somewhat lower decode speed at depth.
Files: `results/benchy-qwen38-iq3s-q8.md`,
`results/server-sweep-qwen38-iq3s-q8_0.log`,
`results/benchy-qwen38-iq3s-q8-vm.log`.
Deviation: none. Swap flat at 603 MB.

### sweep-qwen36-nvfp4 — blocked, stop and ask

`michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF`
`Qwen3.6-35B-A3B-NVFP4-MTP-HQ.gguf` rev `df112dd`, sha256
`777564174a7ccf01a2e9d171ac73206ec3da6b6f6b0124e71a9628ac19f61aa9`,
matches the value recorded at download (`machine-setup`). File size on
disk 20487740864 bytes, matches the planned 20.5 GB.

The model will not load at all, any `--n-cpu-moe`, any `-c`:
`llama_model_load: error loading model: done_getting_tensors: wrong
number of tensors; expected 1101, got 1079`. Confirmed independent of
`--n-cpu-moe` (tried with and without) and of `-c` (tried 98304 and
4096) — not a VRAM condition, a tensor-count mismatch in the GGUF
itself against this llama.cpp build's MTP/`nextn` tensor parsing
(`unused tensor blk.N.nextn.*` warnings printed for every layer just
before the failure, so the loader sees the `nextn` tensors but still
comes up 22 tensors short of what the architecture expects). Not a
memory or ladder condition, so the retry-at-once rule does not apply;
this is a file/build compatibility defect, stop and ask.

Candidate answer: this is the only community NVFP4+MTP repack named in
the runbook for this model; a re-download would refetch the identical
bytes (same revision, same sha256, so a corrupt upstream file would
repeat) — not worth retrying on its own. Options for the coordinator:
drop the drafter and try the plain Qwen3.6 quant this repacker or
another publisher ships without embedded MTP tensors, if one exists;
or skip `sweep-qwen36-nvfp4` and its downstream smoke/guided/blind rows
for this run, noted in the row list as blocked by a bad file, and move
on. The GPU goes on with `sweep-gemma26-nvfp4`, which does not depend
on this block.

### sweep-gemma26-nvfp4

`catlilface/Gemma-4-26B-A4B-NVFP4-GGUF` `Gemma4-26b-NVFP4Q8.gguf` rev
`dc98839`, f16 KV, one arm, no drafter, one slot, `-c 98304`.
`--n-cpu-moe` ladder: 12 pass (13495 MiB), 6 fail (OOM), 9 pass (14719
MiB), 7 pass (15535 MiB), confirmed real with a deep-cell probe before
the full sweep. Started 06:57, closed 07:20.

| depth | tok/s | VRAM MB | MemAvailable |
|--:|--:|--:|--:|
| 4096 | 58.77 | 15585 | 24242 |
| 65536 | 49.56 | 15585 | 24267 |
| 97280 | 45.59 | 15585 | 24232 |

speed/mem, ceiling 97280 @ 45.59 tok/s (vs Mac's 28.2 at 98K).
`gemma26_nvfp4_n_cpu_moe` = 7, `gemma26_nvfp4_clean` = 97280.
Files: `results/benchy-gemma26-nvfp4-nodraft.md`,
`results/server-sweep-gemma26-nvfp4.log`,
`results/benchy-gemma26-nvfp4-nodraft-vm.log`.
Deviation: tried a drafter arm (`--spec-type draft-mtp
--spec-draft-n-max 1`) before re-reading the block text; this build
carries no MTP layers and the runbook already says "one arm, no
drafter" for this block. No server time lost worth noting (failed at
load, no compute). Swap flat around 1.6 GB.

### gemma12-nvfp4-smoke-off

`gemma-4-12b-nvfp4`, level off (model's published default), window
258048 (261120 rounded down to a multiple of 4096, source
`gemma12_nvfp4_clean`), `-c 262144`. `gh auth status` pass. `git stash
list` in `~/code/mendel-benchmark` was empty before `git stash clear`.

`SMOKE-MENDEL model=gemma-4-12b-nvfp4 level=off task=xtend
window=258048 calls=26 distinct=12 longest_run=2 loop=ok:0.40
compactions=0 splits=0 peak=5494 commits=1 clean=yes end=stop wall_s=51
verdict=pass`

Session log thinking check: `usage.reasoning` 0 on every assistant
message, no thinking content block, matches level off. `gemma12-nvfp4-mendel-guided-off` may proceed.
Files: `results/mendel-smoke-gemma12-nvfp4.log`,
`results/server-smoke-gemma12-nvfp4.log`.
Deviation: none.

### qwen38-iq3s-smoke-xhigh

`qwen3.8-27b-iq3s`, level xhigh (owner rule, 2026-09-09), q8_0 arm
(coordinator's pick), window 61440, `-c 65536`. `gh auth status` pass,
mendel-benchmark stash cleared (was empty).

`SMOKE-MENDEL model=qwen3.8-27b-iq3s level=xhigh task=xtend
window=61440 calls=10 distinct=10 longest_run=1 loop=ok:1.00
compactions=0 splits=0 peak=4030 commits=1 clean=yes end=stop wall_s=61
verdict=pass`

Session log thinking check: `content[].type == "thinking"` present on
all 7 assistant turns, with real reasoning text each time (the harness
`usage.reasoning` counter reads 0 for this provider's shape, so that
field alone is not the check — the content block is).
`qwen38-iq3s-mendel-guided-xhigh` may proceed at q8_0.
Files: `results/mendel-smoke-qwen38-iq3s.log`,
`results/server-smoke-qwen38-iq3s-q8.log`.
Deviation: none.

### gemma26-nvfp4-smoke-high

`gemma-4-26b-a4b-nvfp4`, level high (its best Mac row's level), f16 KV,
`--n-cpu-moe 7`, `-c 98304`, window 94208 (coordinator, 97280 rounded
down). `gh auth status` pass, stash cleared (was empty).

`SMOKE-MENDEL model=gemma-4-26b-a4b-nvfp4 level=high task=xtend
window=94208 calls=10 distinct=10 longest_run=1 loop=ok:0.83
compactions=0 splits=0 peak=3340 commits=1 clean=yes end=stop wall_s=30
verdict=pass`

Session log thinking check: real, nonempty `thinking` content blocks
on all 11 assistant turns. `gemma26-nvfp4-mendel-guided-high` may
proceed.
Files: `results/mendel-smoke-gemma26-nvfp4.log`,
`results/server-smoke-gemma26-nvfp4.log`.
Deviation: none.

### gemma12-q4kxl-smoke-off

`gemma-4-12b-q4kxl`, level off, window 258048, `-c 262144`. `gh auth
status` pass, stash cleared (was empty).

`SMOKE-MENDEL model=gemma-4-12b-q4kxl level=off task=xtend
window=258048 calls=8 distinct=8 longest_run=1 loop=ok:1.00
compactions=0 splits=0 peak=2287 commits=1 clean=yes end=stop wall_s=15
verdict=pass`

Session log thinking check: 0 of 9 assistant turns carry a thinking
block, matches off. `gemma12-q4kxl-mendel-guided-off` may proceed.
Files: `results/mendel-smoke-gemma12-q4kxl.log`,
`results/server-smoke-gemma12-q4kxl.log`.
Deviation: none.

All five smokes that do not depend on the blocked `sweep-qwen36-nvfp4`
are done and pass. The guided rows are next.

## Handing over

Not started.
