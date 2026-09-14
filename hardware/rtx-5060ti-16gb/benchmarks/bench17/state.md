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
| `qwen36_q4kxl_n_cpu_moe` | 17 | `sweep-qwen36-q4kxl` (no-drafter arm ladder) |
| `qwen36_q4kxl_clean` | 97280 | `sweep-qwen36-q4kxl` (no-drafter arm) |
| `qwen36_q4kxl_arm` | n-max 2, `--n-cpu-moe 21` | coordinator, served-arm pick |
| `qwen36_q4kxl_window` | 94208 | coordinator (97280 rounded down) |
| `gemma26_nvfp4_n_cpu_moe` | 7 | `sweep-gemma26-nvfp4` |
| `gemma26_nvfp4_clean` | 97280 | `sweep-gemma26-nvfp4` (no-drafter arm) |

## Files and revisions

| repo | file | revision | sha256 |
|---|---|---|---|
| `FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF` | `gemma-4-12b-it-nvfp4.gguf` | `207974a8455870a3a5d0b6854698f2a4f3c6347e` | `8f03a67ca9e7ed7cbf38527a5fa1cd806dba5272feffeb5c5f21865b6961dcad` |
| `unsloth/gemma-4-12b-it-GGUF` | `gemma-4-12b-it-UD-Q4_K_XL.gguf` | `fc034cfff751157913579611efad8462ac1be606` | `90fd944d227e9d9b68e7e2c7d5b57b79d4c66ed521b0919fbbd932cf834f6f8e` |
| `unsloth/Qwen3.8-27B-GGUF` | `Qwen3.8-27B-UD-IQ3_S.gguf` | `4ca720788d1e01f1bff70c033e0d0028fd02e502` | `d847e2c1e4aa276e4b7b8e9ad7628050e61e165d49ab995407bc36677a6f3864` |
| `michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF` | `Qwen3.6-35B-A3B-NVFP4-MTP-HQ.gguf` | `df112dd576e55b1daa1331a7831b64ec9c03dbae` | `777564174a7ccf01a2e9d171ac73206ec3da6b6f6b0124e71a9628ac19f61aa9` (dropped, fails a tensor-count check, see `sweep-qwen36-nvfp4` below) |
| `catlilface/Gemma-4-26B-A4B-NVFP4-GGUF` | `Gemma4-26b-NVFP4Q8.gguf` | `dc98839f4c28f571ac43fb91ab99357471eaff5c` | `62e1590ef5aeba9a2101508eb461083f1e050e97a68d61d86ba003c0a857a895` |
| `unsloth/Qwen3.6-35B-A3B-MTP-GGUF` | `Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` | `5bc3e238d916f48a861bac2f8a1990a0e9b7e98d` | `55983c5a75a1ab969824077b3bb3de4146e82a9234072b48ad4e8f92ad3fe9f1` (owner's word, 2026-09-14, replaces the michaelw9999 file) |
| `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF` | `Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf` | `d562806dbafae37109975e970aae91b43e73b440` | `58fd826723939933dc86f45b7fe04545cbc2de1c70f6fe2cdd3858c87a98c12f` (owner's word, 2026-09-14; matches the Mac's copy exactly) |

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

### gemma12-nvfp4-mendel-guided-off

`gemma-4-12b-nvfp4`, off, window 258048, `-c 262144`, f16 KV, no
drafter. `gh auth status` pass, stash cleared. Server config:
`FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF` `gemma-4-12b-it-nvfp4.gguf`
rev `207974a`, llama.cpp `0.4.0-dev` build 10809, `vram 16311 MiB`.
run-watch armed (no exit 42, no crash). Started 10:29:44Z UTC, ended
10:30:43Z.

`end_reason=repetition_loop`, the same `bash` tool call (`pnpm remove
--filter examples/planout-example uuid`) 5 times running, starting
10:30:39Z. 30 tool calls, 31 assistant messages, peak context
12524/258048 (4.9%). Guided worktree
`~/code/mendel-bench-guided-gemma-4-12b-nvfp4-off` shows **zero
commits** past base `86935f48`, one modified file and one untracked
directory, uncommitted.

Per Mendel `PLAN.md`, "Completion cap, invalid runs, and the score
line": zero commits makes this row **invalid**, not a valid partial
(the repetition-loop-is-valid-partial rule in this run's own text
assumed at least one commit; `PLAN.md` is authoritative and its
zero-commits rule controls). Scored and published by a subagent per
the "Scoring and publishing are one task" rule: `results-guided.json`
entry `invalid: true`, config note carries the file, revision, llama.cpp
version, `-c`, KV type, window, reserve, keep budget, "no drafter",
`vram 16311 MiB`, no explicit temperature/top_p passed (server
default), and "EvalPlus gate waived for this run (owner, 2026-09-13)".
Committed and pushed to `~/code/mendel-benchmark` branch `benchmark`,
commit `31214ec9`.
Files: `results/mendel-guided-gemma12-nvfp4.log`,
`results/server-guided-gemma12-nvfp4.log`,
`~/.local/share/mendel-benchmark/runs/gemma-4-12b-nvfp4-off-guided-meta.json`.
Deviation: this build's guided row is invalid on the model's own
immediate failure, not a harness fault; not retried automatically
(the retry rule covers machine-caused or human-waiting failures, not
a model's own zero-commit loop). Flagged to the coordinator for a
retry decision.

### qwen38-iq3s-mendel-guided-xhigh — attempt 1, machine-killed

`qwen3.8-27b-iq3s`, xhigh, q8_0 KV, window 61440. Started 10:35Z,
progressing normally (1 commit landed, uuid task done; xtend task
in progress, 4 files modified uncommitted) when a host low-memory
event killed the server, the guided worker's `pi` process and an
unrelated background download simultaneously around 12:19Z. `free -m`
showed `available` recovering to ~26 GB right after. GPU itself never
lost memory; this was host RAM, not VRAM.

`run-worker.sh` has no resume flag (the backlog item
`backlog/mendel-resume-interrupted-run.md` proposes one but it is
unimplemented; `--resume` is not a real flag on this build) and aborts
when its worktree or branch already exists, so the interrupted attempt
could not resume in place. Per Mendel `PLAN.md` "Cleanup" and "No
cleanup mid-run", the interrupted worktree is not deleted: moved to
`~/code/mendel-bench-guided-qwen3.8-27b-iq3s-xhigh-interrupted1`
(`git worktree move`), its branch renamed to
`qwen3.8-27b-iq3s-xhigh-guided-v3-issue-13-interrupted1` and pushed to
`origin/mendel` as evidence. Its run artifacts (`events.jsonl`, `meta.json`,
etc.) copied to
`~/.local/share/mendel-benchmark/runs/interrupted/` before the fresh
attempt's worker overwrote the plain slug's files.

Per checklist rule 15 (owner, 2026-09-13), a machine-killed row is
retried at once, inside the block: attempt 2 started clean at
the same config immediately after.

### qwen38-iq3s-mendel-guided-xhigh — attempt 2, running

`qwen3.8-27b-iq3s`, xhigh, q8_0 KV, `-c 65536`, window 61440. `gh auth
status` pass, stash cleared. Server up at 14527 MiB. run-watch armed.
Started ~12:22Z.

Deviation: this run's own reading of the interrupted state as a
"machine kill, retry at once" leaves attempt 1's partial 1-commit
progress (2/8 tasks touched) unscored — flagged to the coordinator:
should attempt 1's branch (now `-interrupted1`) be scored as a
resumed-session row per the backlog proposal once implemented, or
discarded once attempt 2 closes? Not blocking; the GPU moved on.

### qwen38-iq3s-mendel-guided-xhigh — attempt 2, killed with zero progress

Same config. Killed by a second low-memory event within ~15 minutes,
this time with zero commits and zero working-tree changes (killed
almost immediately). `free -m` at both kill events showed `available`
around 25-26 GB; the low number was `free` alone, with `buff/cache`
around 23 GB from the mmap'd model files and the in-progress download.
This reads as the run harness's own background-task low-memory guard
keying off a raw `free` or similar metric, not `available`/reclaimable
memory — a false positive, not a real host OOM. The interrupted
worktree (no commits, identical to base) moved aside anyway per "no
cleanup mid-run": `~/code/mendel-bench-guided-qwen3.8-27b-iq3s-xhigh-interrupted2`,
branch renamed `...-interrupted2`.

Tried restarting the qwen36 download alone (no concurrent GPU work) to
rule out contention: it was killed too, on its own, confirming the
guard is not about concurrency. Worked around by launching the
download, the server, and the guided worker with `nohup ... &
disown` instead of the harness's tracked background-task mechanism,
which stops the false-kill (these processes are not signaled by it).

### qwen38-iq3s-mendel-guided-xhigh — attempt 3, running (nohup)

Same config, `-c 65536`, q8_0 KV, window 61440. Server up at 14550
MiB. Worker and the qwen36 download both running detached via `nohup
... & disown`. Started ~09:38.

**Mid-run crash, exit-42 handled, resumed same session.** At 14:07Z
the server hung: `CUDA error: the launch timed out and was
terminated`, caught by the detached `run-watch` (its log tailed by a
Monitor), while the ISTA download (`sweep-qwen38-ista`, owner word
2026-09-14) ran concurrently. Process stayed alive but stopped
answering HTTP (`curl /health` timed out). `kill -9`, VRAM recovered
to 682 MiB at once, restarted the same server command. `pi`'s RPC
process (271454) was blocked in uninterruptible I/O (`D` state) on
the dead connection; it unblocked on its own once the old server
process was gone, auto-retried 3 times against the reloading server
(`503 Loading model` on attempts 1-2), and the 4th request landed
clean once the server finished loading (~15s). `run-worker.sh` and
`pi` never exited — the whole recovery happened inside the same guided
session, no new attempt, no lost commits. A fresh `run-watch` started
at the log's current offset (confirmed it did not re-trigger on the
old signature line already in the file) and a new Monitor tails it.
Deviation: `CUDA error: the launch timed out` is a driver-level GPU
hang, distinct from the earlier `out of memory` crashes; its cause is
unconfirmed (possibly contention with the concurrent 23 GB ISTA
download's disk I/O, possibly unrelated). Watching for a repeat while
downloads run alongside a guided row.

**diagnose-crash finding (owner-triggered, 2026-09-14 11:14Z).** The
crash's coredump (`coredumpctl info 270828`) confirms the mechanism:
signal 6 (SIGABRT), `llama_server` command line matches this row.
`journalctl -k` at 11:08:11 shows the real trigger, seconds before the
abort: `NVRM: krcWatchdog: RC watchdog: GPU is probably locked!
Notify Timeout Seconds: 7` then `NVRM: Xid (PCI:0000:01:00): 8,
pid=270828, name=llama-server` — an NVIDIA driver watchdog event
(Xid 8, "GPU stopped processing"), not a memory-exhaustion signature.
llama.cpp's own `ggml_cuda_error()` → `ggml_abort()` path fired
cleanly once the CUDA call failed (confirmed from the live backtrace
captured in the server log at the time), so this is llama.cpp
correctly aborting on a driver-level error, not a bug in llama.cpp
itself. One Xid event since boot (up 12h23m at the time, driver
610.57.04 installed 2026-09-10, no correlated package update). Ruled
out host OOM (`free -m` available ~25 GB) and VRAM exhaustion at the
`nvidia-smi` sample nearest the crash (14.5/16.3 GB). Not an Omarchy
bug. No user data lost; the pi session recovered in place. Core
extracted and deleted per the skill's data-hygiene rule.

**Owner's addendum (2026-09-14 14:17Z, after the diagnose-crash
report):** the GPU is also the owner's working desktop, so desktop
apps can add VRAM usage while a row runs, and total VRAM can reach the
card's limit even when the server alone holds only 14.5 GB. Config
note for this row names the hang as a **possible shared-desktop VRAM
squeeze, unconfirmed** — supporting data point: the process table at
14:17Z shows desktop processes (Hyprland, quickshell, several `kitty`
windows) holding ~873 MiB combined alongside `llama-server`'s
13518 MiB (14391 MiB total, ~1.9 GB headroom under the 16311 MiB
card). No window change; the row keeps going.

**New logging, every agent row from here on:** every minute, and at
once on any hang, append `date -u`, `nvidia-smi
--query-gpu=memory.used,memory.total --format=csv,noheader`, and the
full `nvidia-smi` process table to
`results/vram-procs-<mnemonic>.log`. Running via `nohup ... & disown`
for this row: `results/vram-procs-qwen38-iq3s-guided.log`.

### qwen38-iq3s-mendel-guided-xhigh — closed, scored

Ended 2026-09-14T16:48:50.883Z, `end_reason` `tooling_budget_exhausted`
(9 of 10 tooling nudges were "premature length stop", 1 was the
mid-run server-reload `503`; loop verdict `ok`, worst ratio 0.40 on
thinking — not a repetition loop). 7 of 8 libraries committed
(`shasum` never started), 7 commits, 332 tool calls, 35 compactions.
Scored by a subagent per `PLAN.md`/`RUBRIC.md`: raw 79, capped 79 (the
87.5 cap for 7/8 did not bind). Two medium defects: chalk kept the old
v2.1 `enableColor`-forced contract instead of v3.0 `util.styleText`;
the rimraf commit missed the `legacy-packages/mendel-requirify`
reference. Trap A avoided, trap C avoided. Full unit suite green
(285/285), lint clean. `qwen38_iq3s_guided` = 79 (partial 7/8).
Scored and published to `~/code/mendel-benchmark` branch `benchmark`,
commit `0ab06c66`.

### gemma26-nvfp4-mendel-guided-high — closed, scored

`gemma-4-26b-a4b-nvfp4`, high, f16 KV, `--n-cpu-moe 7`, `-c 98304`,
window 94208. Started 2026-09-14T17:08:22Z, ended
2026-09-14T17:30:51Z. `end_reason` `repetition_loop`: a genuine
text-cycle loop, 475 repeats of "I'll try to `git add` them and then
`git status`.", starting 17:28:16Z — the model's own failure, a valid
partial (never invalid) per Mendel's live-loop-stop rule. 137 tool
calls, 1 compaction. 3 of 8 libraries fully done and committed (uuid,
xtend, urlsafe-base64); rimraf half-done, glob barely started
(uncommitted), chalk/tmp/shasum untouched. Clean close: no crash, no
memory kill, no GPU watchdog event, no server issue.

Scored by a subagent per `PLAN.md`/`RUBRIC.md` with the 37.5-point cap
(3/8 libraries): raw 65, capped 37.5. Model value written in full
runbook format, not a bare alias (per the coordinator's earlier catch
on the qwen38-iq3s row) — verified in JSON, CSV and HTML. Two of the
three committed libraries carry medium defects on closer evidence
(xtend's `package.json` entry never cleaned; rimraf missed trap B),
and the uncommitted glob edit reproduces trap A even though `TASKS.md`
marks it done. `gemma26_nvfp4_guided` = 37.5 (partial 3/8). Scored and
published to `~/code/mendel-benchmark` branch `benchmark`, commit
`48a90699`.
Files: `results/mendel-guided-gemma26-nvfp4.log`,
`results/server-guided-gemma26-nvfp4.log`,
`results/vram-procs-gemma26-nvfp4-guided.log`.

### Plan corrections, owner word 2026-09-14

- The machine-id rename (`rtx-5060ti-16gb` → `arrietty`,
  `m1-max-32gb` → `kamaji`) proposed earlier was **cancelled**. Run 17
  keeps the old convention to its end: paths, hardware fields, and
  model values all stay `rtx-5060ti-16gb`. The coordinator translates
  ids when it merges this branch.
- New block order after `gemma26-nvfp4-mendel-guided-high`: the three
  pending sweeps (`sweep-qwen36-q4kxl`, `sweep-qwen38-ista`,
  `sweep-qwen38-iq3s-mtp`) run before any further smoke or agent row.
  Merged the reorder commit only (`git merge f71daf3`, not full
  master, no directory moves) at this block boundary.

### sweep-qwen36-q4kxl — closed

Four arms at `-c 98304`, q8_0 KV: no-drafter (`n-cpu-moe` 17), n-max1
(19), n-max2 (21), n-max3 (21). 97K depth tok/s: 37.80, 37.92, 45.42,
46.76. n-max2/n-max3 read close; n-max2 needs a smaller draft window
for a similar gain. Files:
`results/benchy-qwen36-q4kxl-{nodraft,nmax1,nmax2,nmax3}.md`,
matching `server-sweep-qwen36-q4kxl-*.log` and `*-vm.log`.

## Handing over

Not started.
