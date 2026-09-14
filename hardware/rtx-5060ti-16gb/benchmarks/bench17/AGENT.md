# Run 17 — first run on the Linux box: RTX 5060 Ti 16 GB, llama.cpp only

Ready to start, 2026-09-13. Several days of machine time; the list
below is the order and the run ends when the list ends or the owner
says stop.

You are the runner, on the Linux machine. Read this file, then the
pages each block names at its start, and nothing else. Write all prose
in ASD-STE100 Simplified Technical English.

## What this run is for

The owner's word (2026-09-13): a new GPU, a GeForce RTX 5060 Ti with
16 GB of VRAM, sits in the Linux desktop. The run answers which local
coding models serve on it, at what window and what speed on real
text, and how they do on the agent task. llama.cpp only: this is
NVIDIA hardware. At least one NVFP4 build is on the list because the
card runs NVFP4 natively (Blackwell, compute capability 12.0).

The shape the owner set: first the speed of every candidate up to its
deep context with `llama-benchy`; then the agent smoke of every
candidate; then simulator(mendel) guided for every candidate that
passed its smoke; then simulator(mendel) blind for every candidate
whose guided row finished 8 of 8 libraries, bugs allowed, and only
after every guided row is done. **No EvalPlus in this run** (owner,
2026-09-13): the EvalPlus gate before the agent task is waived for
this run only, and the run's rows say so.

## The order

**This list is the order.**

- `machine-setup`
- `sweep-gemma12-nvfp4`
- `sweep-gemma12-q4kxl`
- `sweep-qwen38-iq3s`
- `sweep-qwen36-q4kxl`
- `sweep-gemma26-nvfp4`
- `gemma12-nvfp4-smoke-off`
- `qwen38-iq3s-smoke-xhigh`
- `qwen36-q4kxl-smoke-high`
- `gemma26-nvfp4-smoke-high`
- `gemma12-q4kxl-smoke-off`
- `gemma12-nvfp4-mendel-guided-off`
- `qwen38-iq3s-mendel-guided-xhigh`
- `qwen36-q4kxl-mendel-guided-high`
- `gemma26-nvfp4-mendel-guided-high`
- `gemma12-q4kxl-mendel-guided-high`
- `gemma12-nvfp4-mendel-guided-high`
- `sweep-qwen38-ista`
- `sweep-qwen38-iq3s-mtp`
- `qwen38-ista-smoke-xhigh`
- `qwen38-ista-mendel-guided-xhigh`
- `mendel-blind-after-guided`
- `retry-sweep`

## Essentials

- `bench17/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION:** `git worktree add ../choose-a-local-llm-run17 -b
  run17` (or `cd` into it if it exists), then `cd
  ../choose-a-local-llm-run17`. Verify with `pwd` and `git worktree
  list`. Every command of this run happens there.
- **Branches, exactly.** You work on `run17` and only on `run17`. The
  coordinator works on `master` in the main worktree of this same
  clone. To take an update: `git merge master` from your run
  worktree, then push `run17`. Never check out `master`, never merge
  `run17` into `master`, never push `master`.
- Then `docs/methodology/checklist.md` and
  `docs/methodology/status-lines.md`, whole, once per session.
- **This machine is Linux, not the Mac.** Some steps of the checklist
  and the method pages are macOS steps. Read them this way:
  - `tools/preflight.sh` reads macOS counters and does not run here.
    Do its job by hand, read-only, before every block:
    `nvidia-smi` (no process on the GPU except the desktop
    compositor; record the `Memory-Usage` value as `vram_start_mb` in
    `state.md`, about 840 MiB on 2026-09-13), `pgrep -fl llama-server`
    (empty), `free -m` (record `MemAvailable`), `df -h ~` (20 GB free
    or more), `gh auth status` (pass). No sudo exists for you on this
    machine: a step that needs `sudo` or `pacman` is stop and ask.
  - There is no wired limit. Where a note would say `wired 25000`,
    write `vram 16311 MiB`. Where a status line prints
    `wired 24.5GB`, print `vram 14.2GB` from
    `nvidia-smi --query-gpu=memory.used --format=csv,noheader`.
  - Memory recovery after a server stops (checklist step 13): wait
    until `nvidia-smi` shows `vram_start_mb` again, then start the
    next server.
  - `vm_stat` and `sysctl vm.swapusage` do not exist. The benchy
    `--post-run-cmd` and `benchmarks/run-watch.sh` read `nvidia-smi`
    and `free -m` instead; the commands below already do.
  - The creep tool (`slow-context-creep`) reads `vm_stat` and does
    not run here. This run reads speed with `llama-benchy` only; the
    `-c` ceiling comes from the ladder in "The ladder" below.
  - No LM Studio, no `mlx_lm.server`, no login items, no wired-limit
    check. The GPU process pattern is `llama-server` alone.
  - The server death signatures on CUDA are `CUDA error`,
    `out of memory`, `cudaMalloc`, `ggml_cuda`, `Segmentation fault`,
    `Aborted`, `Traceback`, `crashed`. Every `run-watch.sh` start
    carries them in `RUNWATCH_SIGNATURES`; the commands below do.
- One model on the GPU at a time, port 8081. Before you start a
  server, `pgrep -fl llama-server` must be empty. Never kill a server
  you did not start.
- **Downloads never block this run** (owner rule, 2026-09-14): fetch
  the llama.cpp binary, `llama-benchy`, the `hf` command, the six model
  files and the four tokenizers named in `machine-setup` when a block
  needs them, and go on. Every file is named there with its repository
  and file name. A different file than the one a block names is stop
  and ask.
- **No temperature and no sampling parameter is passed to any
  server.** The server's own default is the serving sampling. Read the
  values a simulator(mendel) run used from its `meta.json` and put
  them in the row's config note.
- **Effort medium is banned for Qwen3.8** (owner rule, 2026-09-09).
  Its agent blocks run at xhigh, the model's published default. A
  speed block reads decode only and names no level.
- **Harness values are per run.** The worker and the smoke build their
  own pinned config from `~/.pi/agent/models.json`. That file on this
  machine has no `llama` provider yet; `machine-setup` writes it from
  the block in "The pi entries" below and records it in `state.md`.
  Never edit `~/.pi/agent/models.json` in any other way.
- `gh auth status` must pass before any smoke.
- **`git stash clear` in `~/code/mendel-benchmark` right before every
  smoke and every agent row** (owner rule, 2026-09-12,
  `docs/methodology/mendel.md`). Record the `git stash list` output
  before the clear in `state.md`.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says, with the CUDA signatures.
- **Scoring and publishing are one task.** One subagent on the best
  available model, per row, on a scratch path of its own that no
  other subagent shares, does all of it: scores per `PLAN.md`, writes
  the `results-guided.json` (or `results.json`) entry with its matrix
  cells, regenerates the CSV and the HTML report, commits to
  `~/code/mendel-benchmark` on branch `benchmark` and pushes. **Every
  row of this run carries `"hardware": "rtx-5060ti-16gb"` beside
  `serving`, and its `model` value names the machine**, because the
  results files hold rows of two machines from this run on. A bug in
  a run tool goes to a subagent on the best model at once; the run
  does not wait for it.
- Commit on `run17` as results land. Push at every block close and
  message the coordinator session `choose-a-local-llm-db` with the
  block, the config, the result line and the commit id. **No message
  between pushes**: no live progress, no status counts (owner rule,
  2026-09-11). Never run a bare `git stash`.
- Every gate and every stop-and-ask goes to the coordinator session
  with the block, the condition and your candidate answer. Keep the
  GPU busy with the next block that does not depend on it. The owner
  is away; never ask the owner a multiple-choice question.
- Status lines follow `docs/methodology/status-lines.md`. Archive
  evidence before a session closes:
  `tools/archive-evidence.sh hardware/rtx-5060ti-16gb/benchmarks/bench17/results run17`.
- Nothing of an interrupted run is cleaned up mid-run
  (`docs/methodology/mendel.md`, "No cleanup mid-run").
- Every file a block writes goes under
  `hardware/rtx-5060ti-16gb/benchmarks/bench17/results/` or under
  `~/.local/share/choose-a-local-llm/`. Nothing under `/tmp`.

## `machine-setup`

Read `docs/methodology/checklist.md`, "Before the run". This machine
has no llama.cpp, no `llama-benchy`, no model file and no `hf`
command. Every install below is user-level; none needs sudo.

1. **llama.cpp.** No CUDA toolkit is installed and the official
   releases ship no Linux CUDA binary, so the run uses the prebuilt
   from `keypaa/llamaup` (release `v0.4.0`, 2026-09-04, llama.cpp
   tag `v0.4.0`), the `sm120` `cuda12.8` archive, which bundles the
   CUDA runtime libraries. The card reports compute capability 12.0.

   ```bash
   mkdir -p ~/.local/share/choose-a-local-llm/llama.cpp && cd ~/.local/share/choose-a-local-llm/llama.cpp
   curl -L -O https://github.com/keypaa/llamaup/releases/download/v0.4.0/llama-v0.4.0-linux-cuda12.8-sm120-x64.tar.gz
   curl -L -O https://github.com/keypaa/llamaup/releases/download/v0.4.0/llama-v0.4.0-linux-cuda12.8-sm120-x64.tar.gz.sha256
   sha256sum -c llama-v0.4.0-linux-cuda12.8-sm120-x64.tar.gz.sha256
   mkdir -p v0.4.0-sm120 && tar -xzf llama-v0.4.0-linux-cuda12.8-sm120-x64.tar.gz -C v0.4.0-sm120
   ```

   Find `llama-server` inside `v0.4.0-sm120` (`find . -name
   llama-server`), put its directory first on `PATH` for every
   session of this run, and record `llama-server --version` and
   `llama-server --help | grep -i -E 'fit|n-cpu-moe|nvfp4'` in
   `state.md`. A checksum mismatch or a binary that does not start
   with `CUDA` in its version line is stop and ask. If `--help`
   lists no `--fit` flag, drop `--fit off` from every command below
   and confirm on every load log that all layers went to the GPU
   (`offloaded N/N layers to GPU`).
2. **`llama-benchy` and `hf`.**

   ```bash
   pipx install llama-benchy==0.4.0
   uv tool install huggingface_hub[cli]
   llama-benchy --help | head -3; hf --help | head -3
   ```

   Record both versions in `state.md` as `benchy_version` and
   `hf_version`.
3. **Model files.** Download each into
   `~/.cache/llama.cpp/hf/<owner>/<repo>/` with `hf download <repo>
   <file> --local-dir ~/.cache/llama.cpp/hf/<repo>`. Before each
   download, record the repository's current commit as its revision:
   `curl -s https://huggingface.co/api/models/<repo> | python3 -c
   'import sys,json; print(json.load(sys.stdin)["sha"])'`. After
   each, record `sha256sum` of the file. All six files:

   | repo | file | size | block |
   |---|---|--:|---|
   | `FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF` | `gemma-4-12b-it-nvfp4.gguf` | 7.0 GB | `sweep-gemma12-nvfp4` |
   | `unsloth/gemma-4-12b-it-GGUF` | `gemma-4-12b-it-UD-Q4_K_XL.gguf` | 7.4 GB | `sweep-gemma12-q4kxl` |
   | `unsloth/Qwen3.8-27B-GGUF` | `Qwen3.8-27B-UD-IQ3_S.gguf` | 12.0 GB | `sweep-qwen38-iq3s` |
   | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF` | `Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` | 22.9 GB | `sweep-qwen36-q4kxl` (owner's word, 2026-09-14; replaces the michaelw9999 NVFP4 file, which fails a tensor-count check) |
   | `catlilface/Gemma-4-26B-A4B-NVFP4-GGUF` | `Gemma4-26b-NVFP4Q8.gguf` | 15.4 GB | `sweep-gemma26-nvfp4` |
   | `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF` | `Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf` | 12.1 GB | `sweep-qwen38-ista` (owner, 2026-09-14; revision `d562806`, the Mac's, not the repository's newest) |

   Download the first file, start `sweep-gemma12-nvfp4`, and fetch
   the rest while it runs; a download never waits on the GPU and the
   GPU never waits on a download.
4. **Tokenizers for benchy**, the base repositories, all ungated:
   `unsloth/gemma-4-12b-it` (both Gemma-12B builds),
   `unsloth/Qwen3.8-27B`, `unsloth/Qwen3.6-35B-A3B`,
   `unsloth/gemma-4-26B-A4B-it`. benchy fetches a tokenizer on first
   use; record the repo beside every table.
5. **The pi entries.** Write the block in "The pi entries" into
   `~/.pi/agent/models.json` as `providers.llama`, keeping every other
   provider as it is, with a short python that loads the file, sets
   the key and dumps it with `indent=2`. Verify with `pi
   --list-models | grep -E 'gemma-4|qwen3'` and record the output in
   `state.md`. If pi rejects the block, read
   `~/.local/share/mise/installs/pi/latest/pi/docs/models.md` and fix
   the shape; record the fix.
6. **The corpus server.** `cd hardware/m1-max-32gb/research/run4/results
   && python3 -m http.server 8089 --bind 127.0.0.1` in the background
   for the whole run; stop it after the last speed block. The file is
   `corpus-mendel-js.txt`, sha256
   `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`;
   verify it once.
7. **Directories.** `mkdir -p ~/.local/share/choose-a-local-llm
   ~/.local/share/mendel-benchmark`.

Done: every version and every hash in `state.md`, committed. No
result table.

## The ladder

Every speed block needs the largest `-c` that serves. On this card a
`-c` that does not fit fails at load with a CUDA allocation error, so
the ladder is quick:

1. Start at the block's planning `-c`. Load with the block's full
   command. A load that ends in `CUDA error`, `out of memory` or
   `cudaMalloc failed`, or that offloads fewer than all layers (read
   the `offloaded N/N layers to GPU` line; `--fit off` keeps
   llama.cpp from shrinking the context or the layer count on its
   own), is a fail. Halve `-c` until a load passes.
2. Bisect between the last fail and the last pass in multiples of
   8192, at most six loads in all.
3. The pass is real only when a request the size of the deep cell
   serves: the deep benchy cell of the block is that request. A deep
   cell that dies on a CUDA error steps `-c` down by 8192 and reads
   the cell again, inside the block (owner rule, 2026-09-13, retry at
   once).
4. Write `<mnemonic>_c` and the ladder lines in `state.md`. Every
   later block on the same files and KV type reads `-c` from there.

For a MoE block the ladder has one more variable, `--n-cpu-moe N`,
the count of layers whose experts stay in host RAM. The block fixes
`-c` and finds the smallest `N` that loads and serves: start at half
the layer count the load log prints (`n_layer`), halve `N` when a load
passes, take the midpoint when it fails, at most six loads, and end
on the smallest passing `N`. Write `<mnemonic>_n_cpu_moe` in
`state.md`. A layer count you cannot read from the log is stop and
ask.

## The benchy command

The shape, from research run 4 (`benchy_invocation` in
`hardware/m1-max-32gb/research/run4/state.md`), with this machine's
memory sampling:

```bash
llama-benchy --base-url http://127.0.0.1:8081/v1 --model <the alias the server answers to> \
  --tokenizer <tokenizer for this model's base> \
  --book-url http://127.0.0.1:8089/corpus-mendel-js.txt \
  --pp 512 --tg 256 --depth <block's depths, space separated> \
  --runs 2 \
  --post-run-cmd 'sleep 60; nvidia-smi --query-gpu=memory.used,memory.total,temperature.gpu,power.draw,clocks.sm --format=csv,noheader >> hardware/rtx-5060ti-16gb/benchmarks/bench17/results/benchy-<mnemonic>-<arm>-vm.log; free -m | sed -n 2,3p >> hardware/rtx-5060ti-16gb/benchmarks/bench17/results/benchy-<mnemonic>-<arm>-vm.log' \
  --format md --save-result hardware/rtx-5060ti-16gb/benchmarks/bench17/results/benchy-<mnemonic>-<arm>.md
```

`<arm>` is the KV type (`f16`, `q8`) on a dense block, and `nmax0`,
`nmax1` and so on on a drafter block. Every llama-server command in a
speed block carries `--cache-ram 0` for the measurement only; the
published serving command does not. A benchy request adds 768 tokens
over its depth, so the deepest depth of every block is `-c` minus
1024. Read `llama-benchy` and the server log; on a drafter arm read
the `draft acceptance` line of the matching request and put it beside
the cell. `llama-benchy` writes its result file once at the end, so a
dead deep cell loses the shallow cells of the same call: read the
deep cell of a MoE block in its own call.

Done, for every sweep block: one table in `results.md`, one line per
arm and depth: arm, depth, benchy tok/s, sd, prompt tok/s, acceptance
where a drafter runs, VRAM used, `MemAvailable`. Beside it the ladder
lines and the `-c` the block ends on. **A table and no pick.** The
coordinator names the served arm and the KV type.

## `sweep-gemma12-nvfp4`

The NVFP4 build of the dense 12B model, the run's headline NVFP4 row:
it fits the card with room for the trained window. Fixed:
`FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF` `gemma-4-12b-it-nvfp4.gguf`
at the revision `machine-setup` recorded, `--no-mmproj`, f16 KV, no
drafter, `--parallel 1`, alias `gemma-4-12b-nvfp4`. Derived: `-c`,
planning value 262144, the trained window (the Mac served the k-quant
of this model at 262144 f16 in 13.9 GB, so it is expected to fit).
Depths: 4096, 98304, `-c` minus 1024. Tokenizer
`unsloth/gemma-4-12b-it`.

```bash
llama-server -m ~/.cache/llama.cpp/hf/FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF/gemma-4-12b-it-nvfp4.gguf \
  --alias gemma-4-12b-nvfp4 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c <gemma12_nvfp4_c; planning 262144> \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 2>&1 \
  | tee hardware/rtx-5060ti-16gb/benchmarks/bench17/results/server-sweep-gemma12-nvfp4.log
```

Mac numbers to read against, the k-quant at f16: 25.0 at 4K, 9.2 at
245K. Write `gemma12_nvfp4_c` and the clean depth (the deepest cell at
or above 8 tok/s) as `gemma12_nvfp4_clean` in `state.md`.

## `sweep-gemma12-q4kxl`

The Mac's build of the same model, the control for the NVFP4 row on
this card. Fixed: `unsloth/gemma-4-12b-it-GGUF`
`gemma-4-12b-it-UD-Q4_K_XL.gguf` at the recorded revision,
`--no-mmproj`, f16 KV, no drafter, `--parallel 1`, alias
`gemma-4-12b-q4kxl`. Derived: `-c`, planning value 262144. Same
depths, same tokenizer, same command with the file and the alias
changed and the log `server-sweep-gemma12-q4kxl.log`. Write
`gemma12_q4kxl_c` and `gemma12_q4kxl_clean` in `state.md`.

## `sweep-qwen38-iq3s`

The dense 27B model, the best local agent model on the Mac, in the
3-bit build that leaves room for a KV cache on 16 GB. Two arms, one
per KV type, because on this card the type decides the window and the
Mac's pick (f16, for speed on Metal) does not carry over. Fixed:
`unsloth/Qwen3.8-27B-GGUF` `Qwen3.8-27B-UD-IQ3_S.gguf` at the recorded
revision, `--no-mmproj`, no drafter (the drafter lost on every dense
Qwen3.8 build on real text, run 16), `--parallel 1`, alias
`qwen3.8-27b-iq3s`. Derived: `-c` per arm. Planning values from the
Mac's 107 KB per token at f16: about 24576 at f16 and 49152 at q8_0;
the ladder starts at 65536 for both arms. Depths: 4096, 24576, `-c`
minus 1024. Tokenizer `unsloth/Qwen3.8-27B`.

```bash
llama-server -m ~/.cache/llama.cpp/hf/unsloth/Qwen3.8-27B-GGUF/Qwen3.8-27B-UD-IQ3_S.gguf \
  --alias qwen3.8-27b-iq3s --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c <qwen38_iq3s_<arm>_c; planning 65536 start> \
  --cache-type-k <arm> --cache-type-v <arm> --cache-ram 0 \
  --jinja --port 8081 2>&1 \
  | tee hardware/rtx-5060ti-16gb/benchmarks/bench17/results/server-sweep-qwen38-iq3s-<arm>.log
```

Mac numbers to read against, the ISTA 3-bit at f16 with no drafter:
14.1 at 4K, 8.1 at 147K. Write `qwen38_iq3s_f16_c`,
`qwen38_iq3s_q8_c` and the clean depth of each in `state.md`. The
agent blocks of this model take the arm the coordinator names at the
block-close message; until that message arrives, the smoke of this
model waits and the list goes on.

## `sweep-qwen36-q4kxl`

The MoE 35B model in the mainstream build, the one the Mac serves
(owner's word, 2026-09-14: a popular stable release, not a niche
NVFP4 repack; the michaelw9999 file failed a tensor-count check at
load). The file is larger than the card, so part of the experts stay
in host RAM. Fixed: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF`
`Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` at the recorded revision (this repo
embeds the MTP drafter in the file; `--spec-type draft-mtp` turns it
on, as the Mac's row does), `--no-mmproj`, q8_0 KV (the Mac's pick for
this model: f16 did not fit a useful window there and will not here),
`--parallel 1`, alias `qwen3.6-35b-a3b-q4kxl`. `-c 98304` is the search target of this
block (coordinator, 2026-09-13: the Mac's window for this model, twice
the task's 46K); the ladder finds `qwen36_q4kxl_n_cpu_moe`, the
smallest expert offload that serves it. Arms by "The sweep rule" of
`docs/methodology/context-creep.md`: no drafter first, then
`--spec-type draft-mtp --spec-draft-n-max 1`, then 2, then 3, each a
fresh server with the same `N`; stop the climb when an arm reads
slower than the arm before it at every depth, and after a mixed arm
take one more. Depths: 4096, 65536, 97280, the deep cell in its own
call. Tokenizer `unsloth/Qwen3.6-35B-A3B`.

```bash
llama-server -m ~/.cache/llama.cpp/hf/unsloth/Qwen3.6-35B-A3B-MTP-GGUF/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf \
  --alias qwen3.6-35b-a3b-q4kxl --no-mmproj --parallel 1 \
  <arm flags> \
  -ngl 999 --fit off --n-cpu-moe <qwen36_q4kxl_n_cpu_moe> -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 --cache-ram 0 \
  --jinja --port 8081 2>&1 \
  | tee hardware/rtx-5060ti-16gb/benchmarks/bench17/results/server-sweep-qwen36-q4kxl-<arm>.log
```

`<arm flags>` is empty for no drafter and `--spec-type draft-mtp
--spec-draft-n-max <n>` otherwise. Mac numbers to read against, the
k-quant at q8_0 with n-max 3: 43.7 at 4K, 13.0 at 82K. Write
`qwen36_q4kxl_n_cpu_moe` and `qwen36_q4kxl_clean` in `state.md`. The
agent blocks of this model take the arm the coordinator names.

## `sweep-gemma26-nvfp4`

The MoE 26B model in a community NVFP4 build that keeps attention at
Q8. Same shape as `sweep-qwen36-q4kxl`, one arm, no drafter. Fixed:
`catlilface/Gemma-4-26B-A4B-NVFP4-GGUF` `Gemma4-26b-NVFP4Q8.gguf` at
the recorded revision, `--no-mmproj`, f16 KV (the Mac's pick for this
model), `--parallel 1`, alias `gemma-4-26b-a4b-nvfp4`. `-c 98304` is
the search target; the ladder finds `gemma26_nvfp4_n_cpu_moe`.
Depths: 4096, 65536, 97280, the deep cell in its own call. Tokenizer
`unsloth/gemma-4-26B-A4B-it`. Command as above with the file, the
alias, `f16` and the log `server-sweep-gemma26-nvfp4.log`. Mac
numbers to read against, the k-quant at f16 with n-max 2: 60.1 at 4K,
28.2 at 98K. Write `gemma26_nvfp4_n_cpu_moe` and
`gemma26_nvfp4_clean` in `state.md`.

## `sweep-qwen38-ista`

The dense 27B model in the 3-bit build the Mac serves: a second
provider's trade-off of the same model for the same 12 GB budget
(owner, 2026-09-14: both builds target a 16 GB card, and the Mac holds
this build's agent rows, so the pair reads across providers and across
machines). **Fetch the file now**, beside the block that runs; the
download never waits for this block's place in the list. Fixed:
`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF`
`Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf` at revision
`d562806dbafae37109975e970aae91b43e73b440`, the one the Mac runs
(sha256 on the Mac
`58fd826723939933dc86f45b7fe04545cbc2de1c70f6fe2cdd3858c87a98c12f`;
record this machine's and compare, a mismatch is stop and ask),
`--no-mmproj`, q8_0 KV (owner, 2026-09-14: on this card q8_0 buys the
window; `sweep-qwen38-iq3s` measured 65536 at q8_0 against 53248 at
f16), `--parallel 1`, alias `qwen3.8-27b-ista`. The file carries the
MTP head, as the unsloth file does. Derived: `-c`, planning value
`qwen38_iq3s_q8_c` (65536); this file is 79 MB larger, so the ladder
may step down once. Arms by "The sweep rule" of
`docs/methodology/context-creep.md`: no drafter first, then
`--spec-type draft-mtp --spec-draft-n-max 1`, then 2, then 3, each a
fresh server at the same `-c`; stop the climb when an arm reads slower
than the arm before it at every depth, and after a mixed arm take one
more. Depths: 4096, 24576, `-c` minus 1024. Tokenizer
`unsloth/Qwen3.8-27B`, the same base tokenizer.

```bash
hf download ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf \
  --revision d562806dbafae37109975e970aae91b43e73b440 \
  --local-dir ~/.cache/llama.cpp/hf/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF

llama-server -m ~/.cache/llama.cpp/hf/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF/Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf \
  --alias qwen3.8-27b-ista --no-mmproj --parallel 1 \
  <arm flags> \
  -ngl 999 --fit off -fa on -c <qwen38_ista_c; planning 65536> \
  --cache-type-k q8_0 --cache-type-v q8_0 --cache-ram 0 \
  --jinja --port 8081 2>&1 \
  | tee hardware/rtx-5060ti-16gb/benchmarks/bench17/results/server-sweep-qwen38-ista-<arm>.log
```

The server reads its sampling defaults from the file. This file sets
`min_p 0.0`; the unsloth file sets none, so its server applies
`0.05`. Pass no sampling flag (Essentials), and let every config note
of this build name `min_p`. Mac numbers to read against, this file at
f16 on Metal: no drafter 14.1 at 4K and 8.1 at 147K; the drafter lost
at every depth there. Write `qwen38_ista_c` and the clean depth of
every arm (`qwen38_ista_clean` for the no-drafter arm) in `state.md`.
The agent blocks of this build take the arm the coordinator names.

## `sweep-qwen38-iq3s-mtp`

The drafter climb on the unsloth file, so the two providers read at
the same arms. Fixed: the files and flags of `sweep-qwen38-iq3s`, q8_0
arm, `-c` from `qwen38_iq3s_q8_c`. The no-drafter cells of that block
are the base arm; do not read them again. Arms n-max 1, then 2, then 3,
by the climb rule above. Same depths, same tokenizer; logs
`server-sweep-qwen38-iq3s-q8-nmax<n>.log`. Speed only: the guided row
of this build runs with no drafter, and a drafter changes speed, not
output.

## The smokes

Read `docs/methodology/mendel.md`, "The smoke" and "Window and
budget". One smoke per build, the first time it meets the simulator
on this machine. Every smoke serves the build with the arm the
coordinator named at its sweep's close, with `--cache-ram 0` removed
and `-c` from `state.md`, and pins the harness window
`<mnemonic>_window`: the block's clean depth rounded down to a
multiple of 4096, at or under `-c`, never smaller (owner rule,
2026-09-06). Write the window with its source in `state.md` before the
smoke. The window steps down by 8192 only after a server death at the
window itself, written in `state.md` and the config note.

```bash
SMOKE_MENDEL_CONTEXT_WINDOW=<window> benchmarks/mendel-smoke.sh <alias> <level> 2>&1 | tee hardware/rtx-5060ti-16gb/benchmarks/bench17/results/mendel-smoke-<mnemonic>.log
```

Pass is one commit, clean tree, no repetition loop, inside the cap. A
fail means the guided block of that build does not run; write the
smoke line and go on. A server that dies during the smoke is a fail of
this config, not a retry. **After every smoke, read its session log
for the thinking content**: a level `off` shows no thinking block,
`high` or `xhigh` shows one on most turns. A mismatch means the pi
entry did not reach the server; that is stop and ask, with the entry
and the first request of the log as the evidence, and the guided
block of that build waits.

- `gemma12-nvfp4-smoke-off`: alias `gemma-4-12b-nvfp4`, level `off`,
  the model's published default (its template defaults
  `enable_thinking` to false), the level of every Mac row of this
  model. Window from `gemma12_nvfp4_clean`.
- `qwen38-iq3s-smoke-xhigh`: alias `qwen3.8-27b-iq3s`, level `xhigh`,
  the model's published default (owner rule, 2026-09-09). The arm and
  `-c` the coordinator named; window from that arm's clean depth.
- `qwen36-q4kxl-smoke-high`: alias `qwen3.6-35b-a3b-q4kxl`, level
  `high`, which is thinking on for this model in the harness map, its
  published default and the level of its best Mac row (63 guided).
  The drafter arm the coordinator named. Window from
  `qwen36_q4kxl_clean`.
- `gemma26-nvfp4-smoke-high`: alias `gemma-4-26b-a4b-nvfp4`, level
  `high`, thinking on, the level of its best Mac row (47.5 blind).
  Window from `gemma26_nvfp4_clean`.
- `gemma12-q4kxl-smoke-off`: alias `gemma-4-12b-q4kxl`, level `off`,
  as the NVFP4 build. Window from `gemma12_q4kxl_clean`.
- `qwen38-ista-smoke-xhigh`: alias `qwen3.8-27b-ista`, level `xhigh`,
  the model's published default (owner rule, 2026-09-09). Another
  file, so its own smoke. The arm the coordinator named; window from
  that arm's clean depth.

## The guided rows

Read `docs/methodology/mendel.md`. simulator(mendel) guided, prompt
v3.0, base tag `benchmark-guided-base`. Fixed per block: the server of
the matching smoke unchanged, the level of the smoke. Derived: the
window from `state.md`; `maxTokens` and `reserveTokens` 8192, the
worker's pin; keep budget 8192 under a window of 65536, pi's default
above it. The EvalPlus gate is waived for this run (owner,
2026-09-13); the config note says so.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<window> ./run-worker.sh <alias> pi guided <level>
```

Branch by the slug the worker forms; no branch of that name exists,
because every alias of this run is new. Row `model` value:
`<alias> (<publisher> <quant>, <level>, rtx-5060ti-16gb)`, for
example `gemma-4-12b-nvfp4 (FreedomAISVR NVFP4, off, rtx-5060ti-16gb)`;
`model_id` the repo and file; `hardware` `rtx-5060ti-16gb`. The config
note carries the file and its revision, the llama.cpp version, the
`-c`, the KV type, `--n-cpu-moe` where used, the drafter arm, the
window, the reserve, the keep budget, the compaction count, the
source block of each value, `vram 16311 MiB`, the temperature and
top_p from the run's `meta.json`, and the line "EvalPlus gate waived
for this run (owner, 2026-09-13)". Verify `peak_context` with the
counter before the row commits. A row that ends on the model's own
repetition loop is a valid partial. A server that dies mid-run is a
row at the state it reached, written as such, and never a reason to
lower the window on your own; the step down by 8192 is the
coordinator's call at the block-close message. The 300-minute wall
gives a partial, which is a row and not a failure. Write
`<mnemonic>_guided` in `state.md` with the score, the libraries done
and the end reason.

- `gemma12-nvfp4-mendel-guided-off`: alias `gemma-4-12b-nvfp4`, `off`.
- `qwen38-iq3s-mendel-guided-xhigh`: alias `qwen3.8-27b-iq3s`, `xhigh`.
- `qwen36-q4kxl-mendel-guided-high`: alias `qwen3.6-35b-a3b-q4kxl`, `high`.
- `gemma26-nvfp4-mendel-guided-high`: alias `gemma-4-26b-a4b-nvfp4`, `high`.
- `gemma12-q4kxl-mendel-guided-high`: alias `gemma-4-12b-q4kxl`, `high`.
- `gemma12-nvfp4-mendel-guided-high`: alias `gemma-4-12b-nvfp4`, `high`.
- `qwen38-ista-mendel-guided-xhigh`: alias `qwen3.8-27b-ista`, `xhigh`.

The two Gemma-12B rows run at `high`, thinking on, not at the `off`
of their smokes (owner, 2026-09-14): no Mendel run at thinking off
(`benchmarks/PLANNING.md`). The `off` smokes cover them, because one
smoke covers every level of a build. Their window is the window of
their smoke. The `off` row of the NVFP4 build stays as the record of
its attempt and is not retried. After the first turns of each of the
two rows, read the session log for a thinking block; no thinking block
means the level did not reach the server, and that is stop and ask.

## `mendel-blind-after-guided`

simulator(mendel) blind, prompt v1.1, base tag `benchmark-blind-base`,
for every build whose guided row reached 8 of 8 libraries, bugs and
defects allowed (owner, 2026-09-13). This block starts only when every
guided row above is closed or dropped by its smoke. The builds run in
the order of the guided list, each with the server, the level and the
window of its guided row:

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<window> ./run-worker.sh <alias> pi blind <level>
```

Same row rules as the guided rows. Write `<mnemonic>_blind` in
`state.md`. A build under 8 of 8 gets one line in `results.md` saying
it did not qualify.

## `retry-sweep`

The run's killed or interrupted rows, oldest first, in fresh
worktrees, while the owner is away, under the retry rule of
`docs/methodology/mendel.md`. A row that ended on the model's own
repetition loop is a valid partial and is not retried. Only rows that
waited on a human land here; everything the runner could repeat was
retried inside its block.

## The pi entries

`providers.llama` for `~/.pi/agent/models.json`. The `contextWindow`
values are placeholders that the smoke and the worker overwrite in
their pinned copies; the shapes are the ones research run 2 recorded
for llama-server (`chat-template` with `enable_thinking` for the
binary-thinking models, `reasoning_effort` for the graded one).

```json
{
  "name": "llama-server",
  "api": "openai-completions",
  "baseUrl": "http://127.0.0.1:8081/v1",
  "apiKey": "no-key",
  "models": [
    {
      "id": "gemma-4-12b-nvfp4",
      "name": "Gemma 4 12B NVFP4 (llama-server)",
      "reasoning": true,
      "input": ["text"],
      "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
      "contextWindow": 262144,
      "maxTokens": 8192,
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false,
        "thinkingFormat": "chat-template",
        "chatTemplateKwargs": { "enable_thinking": { "$var": "thinking.enabled" } }
      },
      "thinkingLevelMap": { "off": "off", "minimal": "off", "low": "low", "medium": "medium", "high": "high", "xhigh": "high", "max": "high" }
    },
    {
      "id": "gemma-4-12b-q4kxl",
      "name": "Gemma 4 12B UD-Q4_K_XL (llama-server)",
      "reasoning": true,
      "input": ["text"],
      "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
      "contextWindow": 262144,
      "maxTokens": 8192,
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false,
        "thinkingFormat": "chat-template",
        "chatTemplateKwargs": { "enable_thinking": { "$var": "thinking.enabled" } }
      },
      "thinkingLevelMap": { "off": "off", "minimal": "off", "low": "low", "medium": "medium", "high": "high", "xhigh": "high", "max": "high" }
    },
    {
      "id": "gemma-4-26b-a4b-nvfp4",
      "name": "Gemma 4 26B-A4B NVFP4 (llama-server)",
      "reasoning": true,
      "input": ["text"],
      "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
      "contextWindow": 98304,
      "maxTokens": 8192,
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false,
        "thinkingFormat": "chat-template",
        "chatTemplateKwargs": { "enable_thinking": { "$var": "thinking.enabled" } }
      },
      "thinkingLevelMap": { "off": "off", "minimal": "off", "low": "low", "medium": "medium", "high": "high", "xhigh": "high", "max": "high" }
    },
    {
      "id": "qwen3.6-35b-a3b-q4kxl",
      "name": "Qwen3.6 35B-A3B UD-Q4_K_XL (llama-server)",
      "reasoning": true,
      "input": ["text"],
      "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
      "contextWindow": 98304,
      "maxTokens": 8192,
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false,
        "thinkingFormat": "chat-template",
        "chatTemplateKwargs": { "enable_thinking": { "$var": "thinking.enabled" } }
      },
      "thinkingLevelMap": { "off": "off", "minimal": "off", "low": "low", "medium": "medium", "high": "high", "xhigh": "high", "max": "high" }
    },
    {
      "id": "qwen3.8-27b-iq3s",
      "name": "Qwen3.8 27B UD-IQ3_S (llama-server)",
      "reasoning": true,
      "input": ["text"],
      "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
      "contextWindow": 49152,
      "maxTokens": 8192,
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false,
        "thinkingFormat": "chat-template",
        "chatTemplateKwargs": { "reasoning_effort": { "$var": "thinking.effort" } }
      },
      "thinkingLevelMap": { "off": null, "minimal": null, "low": "low", "medium": "medium", "high": "medium", "xhigh": "xhigh", "max": "xhigh" }
    },
    {
      "id": "qwen3.8-27b-ista",
      "name": "Qwen3.8 27B ISTA GSQ-RCO IQ3_S-mtp (llama-server)",
      "reasoning": true,
      "input": ["text"],
      "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
      "contextWindow": 61440,
      "maxTokens": 8192,
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false,
        "thinkingFormat": "chat-template",
        "chatTemplateKwargs": { "reasoning_effort": { "$var": "thinking.effort" } }
      },
      "thinkingLevelMap": { "off": null, "minimal": null, "low": "low", "medium": "medium", "high": "medium", "xhigh": "xhigh", "max": "xhigh" }
    }
  ]
}
```

The maps map down (owner rule, 2026-09-14,
`benchmarks/PLANNING.md`, "A pi thinking map maps down"). The
coordinator wrote the fixed maps and the `qwen3.8-27b-ista` entry into
`~/.pi/agent/models.json` on 2026-09-14; the file already holds them.

## Not in this run

- EvalPlus on any block (owner, 2026-09-13). LM Studio, MLX, Bonsai,
  any vision task, any creep.
- The dense 27B builds at NVFP4 (17 GB and up): they do not fit this
  card with a KV cache and a dense model with layers in host RAM
  serves under the floor. Noted for a later run.
- unsloth's own NVFP4 checkpoints: they are safetensors for vLLM, not
  GGUF; the GGUF repacks of this run come from the community and the
  rows name their publisher.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state left behind, evidence archived. The
coordinator adds the findings to
`hardware/rtx-5060ti-16gb/benchmarks/INDEX.md`, writes `report.md`,
names the served arm and the KV type of every row, builds the site
section for this setup from the tables, writes the final derived
values into the owner's harness file, and publishes.
