# Research run 1 — state

Created 2026-09-20 by the coordinator. No session has run.

Start here: read `AGENT.md`, then `index.md`, which is the order. Log
every session below, and close each one with a handing-over section.

## Versions and sources

The executor writes each one here as it installs or downloads it.

| name | value | test |
| --- | --- | --- |
| `laya` package | 0.3.4 | `harness` |
| checkpoint revisions | `convaiinnovations/laya` `1c5edc17a7acd8701df6fc341c0d179f1c62c982` (the bundle, all three checkpoints); the standalone repos `laya-multilingual` `052592a1` and `laya-typed-decisions` `f9ab0b22` are not used | `harness` |
| authors' repository commit | | `laya-claims` |
| datasets, with licence and commit | | `laya-claims`, `laya-portuguese` |

## Session 1 — 2026-09-21, executor on `arrietty`

Started at 00:29 on the coordinator's go: benchmark run 28 is closed and
the card is free.

Machine checks at the start. `tools/preflight.sh` exits 1 on this
machine. Four lines are not `ok`, and all four read macOS values that
Linux does not have: `ask apps` (no machine file), `fix login-items`
(`mac-services.sh`), `ask wired-limit` (`iogpu.wired_limit_mb`) and
`ask memory` (`sysctl` page size and swap). Bench 23 met the same
thing and did the checks by hand. This session does the same, and the
run goes on:

- `nvidia-smi`: 954 / 16311 MiB used, graphics only (Hyprland,
  quickshell, Xwayland, kitty, a browser). No compute job.
- `pgrep -x llama-server`: empty. No `mlx_lm`, no LM Studio, no Docker.
- `free -m`: 10570 MB free, 19491 MB available, swap 11364 MB used at
  the start. The swap level is pre-existing; judge it by its growth.
- `df -h ~`: 20 GB free on `/home`.
- `gh auth status` passes. The Claude login has 647 h left.
- Python 3.14.7 on the machine, `uv` 0.12.10, kernel 7.2.3-arch1-3.

Watcher. `benchmarks/run-watch.sh` needs `RUNWATCH_SERVER_LOG` or
`RUNWATCH_OUTPUT`, and this run serves no model and writes no server
log. It runs with the memory log as its own growth file, so the
silence probe never fires and the watcher is only the memory record,
which is what this run needs from it. `RUNWATCH_GPU_MIN_MB=0` turns
off the `llama-server` GPU check, because there is no server.
Log: `~/.local/share/choose-a-local-llm/research1-mem.log`. First
line 00:30:48, `free_mb=19512 gpu_used_mb=954`.

### `harness` — closed

What the package does, against the item's description:

- **A checkpoint is forced by argument.** `Router.predict(state,
  questions, model="english"|"multilingual"|"typed-decisions")` takes
  the explicit model first, before every other signal. The runner does
  not need the Router at all: it builds `laya.agent.Agent(repo,
  subfolder=...)` directly, which is what the Router does under the
  name.
- **One repository, not three.** The package default is one bundle
  repo, `convaiinnovations/laya`, with the two other checkpoints in
  the subfolders `multilingual` and `typed-decisions`. The three
  standalone repos of the item exist (`Router(standalone_repos=True)`)
  but the package does not use them. The run uses the bundle, and one
  revision covers all three checkpoints.
- **One call answers one state.** `Agent.system_one` puts every
  question of one state in one forward pass. There is no API for
  several states in one pass. `collate_items` accepts more, so
  `--batch N` of the runner puts N cases in one forward pass through
  the same package primitives. `--batch 1` is the package's own path.
- **The shipped temperature is already applied.** The checkpoint config
  carries `temperature` per question type and `temperature_by_options`
  per type and option count, and `system_one` divides the logits by it.
  "As shipped" therefore means "with the authors' fitted temperature",
  not "raw". `--fit-temperature` replaces that scale with one scalar
  fitted by NLL on the first half of the cases, and reports the second
  half.
- **The runner reproduces `system_one`.** Measured on the harness
  cases: the largest difference in any probability is 5e-5, which is
  the rounding `system_one` applies to four decimals.
- **The package falls back to the CPU without failing.** A placement
  error or an inference OOM moves the model to the CPU, prints a
  warning and goes on. A latency number could silently be a CPU
  number. The runner stops with exit 2 when the agent does not sit on
  the device that was asked for, and it prints the device in every
  summary.
- **Options have a budget.** `head_max_len` is 192 tokens for the
  question and all its options together, 48 tokens per option. A
  question with too many options raises. MASSIVE with 20 options is
  near that budget; `laya-portuguese` checks it.
- **Truncation keeps the head of the state**, not the tail
  (`truncate_left=False`).

Metric definitions of the runner, for every table of this run:
accuracy is argmax against the label; Brier is the multiclass sum
`sum_i (p_i - y_i)^2`, so it runs from 0 to 2; ECE is the package's own
`ece_score` with 15 bins, over the probability of the predicted option.

CUDA works on this card: torch 2.14.0+cu130 carries `sm_120` and the
model runs in bfloat16 on the GPU. The authors' Blackwell warning does
not apply here.

Environment: `scratchpad/laya-venv`, `uv venv --python 3.12`, Python
3.12.14. `scratchpad/` is now in `.gitignore`.

### `laya-cost` — CUDA cells closed, CPU cells moved to the end of the run

The CUDA cells are in `results.md`. All 24 cells and the nine cold
loads ran with no failure, 01:01, and the card went back to its 954 MB
desktop baseline.

**The CPU cells run last, after every GPU test.** Measured reason: one
CPU call with 50 questions takes 23.4 s on this machine, so the CPU
half of `laya-cost` needs about two hours. A latency number needs a
quiet machine, so nothing else may run beside it; holding every GPU
test behind it would leave the card idle for two hours with runnable
work queued. The order in `index.md` does not change: `laya-cost` is
one item, and its CPU half is the last thing the run does.

Call counts for the CPU cells, set from the measured cost so that no
cell runs over about five minutes: 200 calls at 1 and 5 questions,
64 calls at 10 questions, 20 calls at 50 questions. The GPU cells all
keep the full 200. A p95 over 20 calls is weak, and the table says the
count for every row.

The authors' typed-decisions dataset is not public: both
`convaiinnovations/typed-decisions` and
`convaiinnovations/laya-typed-decisions` answer 401. Their part B (2,000
decisions, the 0.766 headline) therefore cannot run here, and it
becomes a "not public" row in `laya-claims`. The twelve other datasets
their scripts name all answer.

### `laya-claims` — blocked on a permission, goes to `retry-sweep`

The test is "run the authors' notebook code, unchanged except for paths
and device". I built that script:
`results/laya-claims/notebook-as-script.py`, generated from
`research/scripts/laya_benchmark_colab.ipynb` of
`https://github.com/NandhaKishorM/laya` at commit
`42626c348753fbb17572a813127df2278a1ec527`. The only changes are the
three the header of the file names: the `pip install` cell and the
Colab download cell are dropped, and the `%%writefile` magic becomes a
real file write. The notebook already runs on `cuda` and already
downloads the checkpoints itself, so neither path nor device needed a
change.

The first attempt ran and reached cell 6 before I stopped it, because
a pipe hid its progress. Every later attempt is refused by the
permission classifier with `[Code from External]`. Two forms were
tried, both refused. Only a human can allow it.

What the first attempt already showed, and what is therefore not in
doubt: the card is seen (RTX 5060 Ti, 16311 MiB, capability 12.0);
`laya` is 421.29M parameters (394.78M encoder, 26.51M head), 28
layers, hidden 1024, vocabulary 50368, `max_len` 512;
`laya-multilingual` is 321.91M (306.94M encoder, 14.97M head), 22
layers, hidden 768, vocabulary 256000, `max_len` 1024. `laya` ships
fitted temperatures, `laya-multilingual` ships 1.0 for all three
question types, which is the authors' own words in the notebook: it
ships uncalibrated.

Correction to the earlier note in this file: the authors'
typed-decisions set IS public. It is `LocalLLaMA/typed-decisions`, not
`convaiinnovations/typed-decisions`, and the first attempt loaded it:
400 cases, 2,000 questions, four workflows, with soft teacher labels.
So their part B can run once the permission is given.

The notebook also covers only `laya` and `laya-multilingual`; their
`research/scripts/bench_apps.py` is the script that covers all three
checkpoints and the six application themes. It needs the same
permission.

The run goes on with `laya-portuguese`, which uses this repo's own
runner and no external code.
