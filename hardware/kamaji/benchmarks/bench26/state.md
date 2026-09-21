# Run 26 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `wired_limit` | 25000 | `sysctl -n iogpu.wired_limit_mb`, must read 25000 |
| `llama_server_prism` | `~/.local/share/choose-a-local-llm/llama.cpp-prism/release/bin/llama-prism-b10685-7dffb15/llama-prism-b10685-7dffb15/llama-server` | the fork, Metal build |
| `prism_fork_commit` | `7dffb158d`, release `prism-b10685-7dffb15`, build 10685, macOS arm64 Metal | the fork |
| `budget_flags_present` | yes, both | the server check |
| `bonsai2_27b_pq2_mac_c` | 262144 | `bonsai2-pq2-ladder-mac` |
| `bonsai2_27b_ptq1_mac_c` | 262144 | `bonsai2-ptq1-ladder-mac` |
| `bonsai2_pq2_mac_clean` | 40982 | `sweep-bonsai2-pq2-mac` |
| `bonsai2_ptq1_mac_clean` | 163858 | `sweep-bonsai2-ptq1-mac` |
| `served_pack` | PTQ1_0, `bonsai2-27b-ptq1-mac` | no name arrived from the coordinator at the second sweep's close; the deeper clean depth (163858 against 40982) decides, by the runbook |

The card's rows to read against, from `bench24`: PQ2_0 at q8_0 serves
`-c 212992` and reads 46.0 tok/s at 4K and 14.5 at 212K; at f16 it
serves 122880 and reads 46.3 and 25.1. PTQ1_0 at q8_0 serves 245760 and
reads 41.7 and 12.8. EvalPlus on PQ2_0 at a 25209 budget: 0.982/0.939,
no empty, 7 forced. Blind agent row: 59.5, peak context 192679 of a
208896 window, no compaction.

## Machine setup, 2026-09-18 UTC

- Preflight all ok. Start numbers: wired 1755 MB, free 18658 MB, swap used 0 MB. Balloon needed.
- EvalPlus 0.3.1, `EVALPLUS_PYTHON=~/.venvs/local-llm-bench/bin/python`. Eval tools `e38c467`.
- Fork release `prism-b10685-7dffb15`, the card's build. Archive sha256 `7fffa7a40c74f3e9bd78f3f2f9f12f9befb7b13af45d5a69c239cf3fd37b9045`, equal to the GitHub digest.
- Deviation: `gh release download` timed out on `release-assets.githubusercontent.com`. The archive came from `curl` on the release URL. The newer `prism-b10709-9a9394a` was not used, to match the card.
- Files at revision `6ed5e12bf84b7a63069882c91dd9e9218647d17b`, in the HF cache. Sizes equal the table.
  - PQ2_0 7206168928 B, sha256 `3907dc1658db1f78a9826bf8d5bcb8dc65db0d466388937af57f2294fae62ec1`.
  - PTQ1_0 5946648928 B, sha256 `53107f530aa52eb00912263ab1ee29bd199261c87cd7b4ad4ca1318c1fe33ee3`.
- Probe: PQ2_0, `-c 8192`, f16 KV, xhigh, "17*23". Answer `391`, finish `stop`. The binary works.
- Sampling the server applied (from `/props`): temperature 1.0, top_k 20, top_p 0.95, min_p 0.05, repeat_penalty 1.0. The server default has `min_p 0.05`, as on the card. EvalPlus sends temperature 0 itself.
- Corpus server on port 8089, sha256 checked.

## bonsai2-pq2-ladder-mac and sweep-bonsai2-pq2-mac

- Ladder: `-c 262144` (the trained context) loaded at the first try, f16 KV, wired limit 25000. Server log `results/server-pq2-c262144.log`. The floor stops the sweep at 49K to 65K, so no request near 262K ran. The ladder proof is the deepest clean sweep row. Deviation: a request of about 262K would need hours of prefill at 60 tok/s and decode is under the floor from 65K on, so it was not sent.
- Creep tool `e38c467`, pause 60 s, `STALL_S` 2400. Files: `results/creep-bonsai2-pq2-mac.tsv`, `results/creep-bonsai2-pq2-mac-cross.tsv`.
- The floor crosses between 40982 (9.50) and 65578 (7.91). The 49198 row (8.66) has swap growth of 162 MB and stopped the second creep, so it is not a clean row. `bonsai2_pq2_mac_clean` is 40982.
- Compression pages ran high on every row (260K at 4K), free memory 62 to 80 MB. Swap did not grow until 49K.

## bonsai2-ptq1-ladder-mac and sweep-bonsai2-ptq1-mac

- Ladder: `-c 262144` loaded at the first try, f16 KV. It served real requests to 163858 deep. Server log `results/server-ptq1-c262144.log`.
- Three creeps of the same server, same tool `e38c467`, pause 60 s, `STALL_S` 2400. Files: `results/creep-bonsai2-ptq1-mac.tsv` (4K to 65K, no ceiling found), `results/creep-bonsai2-ptq1-mac-deep.tsv` (65K to 197K).
- Swap started at 146 MB. The 196618 row (8.18 tok/s) has swap growth of 130 MB and stopped the creep, so it is not clean. `bonsai2_ptq1_mac_clean` is 163858 (9.07). The floor crossing lies past 164K and was not measured clean.

## bonsai2-calibrate-think-mac

- PTQ1_0 at `-c 32768`, f16 KV, no budget flag, xhigh (resolved xhigh in every row). File `hardware/kamaji/calibrations/calibration-bonsai2-ptq1-mac-xhigh-think.json`. Server log `results/server-ptq1-calibrate.log`, log `results/calibrate-ptq1.log`. Wall 145.9 min.
- 6 converged, 4 cut at 30000 (`length`): HumanEval/32, /39, /99, /145. Four `length` stops in ten: the thinking does not converge on those problems. No converged row has an empty answer.
- Budgets (`THINKING_BUDGET_MARGIN` 1.5): `bonsai2_ptq1_think_budget` 16056, `bonsai2_ptq1_answer_budget` 2048, `bonsai2_ptq1_max_tokens` 18104. Longest converged reasoning 10704 tokens, longest answer 330.

## bonsai2-budget-xhigh-mac

- PTQ1_0, `-c 32768`, f16 KV, xhigh, `--reasoning-budget 16056` with the fixed message, `EVALPLUS_MAX_NEW_TOKENS=18104`, 6 problems seeded from the calibration. Server log `results/server-bonsai2-budget-xhigh-mac.log`.
- One part, no crash: 07:14Z to 12:51Z, 337 min. Calibration wall 145.9 min. Wall 482.9 min.
- Base 0.988, plus 0.939. Empty 0/164 (from the samples). Forced 7/164 (from `finish.jsonl`): HumanEval/32, /39, /80, /99, /129, /137, /145.
- Swap did not grow in the run. The watcher raised one silence probe that queued behind a live turn, as it says it can.
- The card scored 0.982/0.939 at a 25209 budget with 7 forced.

## bonsai2-forced-rerun-mac

- Same PTQ1_0 config as the budget run, without the two reasoning flags, `EVALPLUS_MAX_NEW_TOKENS=30000`. The 4 forced-failed problems re-ran: HumanEval/32, /39, /99, /145. Server log `results/server-bonsai2-forced-rerun-mac.log`.
- One part, no crash: 13:06Z to 15:07Z, 121 min. Pause for Docker before the start, machine idle.
- Result: all 4 hit `length` at 30000 tokens, all reasoning (about 1800 s each). Cells: forced-pass 3 (HumanEval/80, /129, /137), forced-fail-loop 4, forced-fail-late 0, forced-fail-wrong 0. Corrected think budget: unchanged, no late answer.
- With the natural re-run the score is 0.976 base and 0.939 plus on the 4 problems merged into the run (base 0.988 before), because the 4 loops are empty answers. The budgeted run score stays 0.988/0.939.

## bonsai2-smoke-xhigh-mac

- Gate: budget run base 0.988, above 0.800. Server PTQ1_0 `-c 262144`, f16 KV, `--cache-ram 0` (deviation: the runbook allows it for the measurement only; kept because the wired memory reads 25.8 GB at load), no drafter, no reasoning flag.
- Window `bonsai2_ptq1_window` 159744 (clean depth 163858 rounded down to 4096). Reserve 8192.
- pi entry `bonsai2-27b-ptq1-mac` added to `~/.pi/agent/models.json`; original saved as `~/.pi/agent/models.json.bak-run26`.
- Smoke line: `SMOKE-MENDEL model=bonsai2-27b-ptq1-mac level=xhigh task=xtend window=159744 calls=10 distinct=10 longest_run=1 loop=ok:1.00 compactions=0 splits=0 peak=5106 commits=1 clean=yes end=stop wall_s=139 verdict=pass`. The session log holds 7 thinking blocks. Log `results/mendel-smoke-bonsai2-ptq1.log`.

## bonsai2-mlx-probe-mac

- Resumed 2026-09-20 on the coordinator's word. `git merge origin/master` into `run26` was clean (merge commit `2b6ba3d`). Preflight all ok, free disk 120 GB.
- Pack `prism-ml/Ternary-Bonsai-2-27B-mlx-2bit` at revision `3f926b415992eaa2ae9dd7b573706494d6bbf787`, in `~/.local/share/choose-a-local-llm/mlx-bonsai2/pack`. `model.safetensors` is 8595477990 bytes, equal to the runbook; sha256 `130de5925082c168b7866b2e91b52e44abbafc99017e3ca352b77b5b55a269ed`.
- Venv `~/.local/share/choose-a-local-llm/mlx-bonsai2/venv`: `mlx==0.32.0`, `mlx-lm==0.31.3`, `mlx-metal==0.32.0`, `numpy==2.5.3`. Full `pip freeze` in `results/mlx-venv-freeze.txt`.
- Server command as the runbook says (`--prompt-cache-size 2`, port 8081). The log `results/server-mlx.log` ends with `ValueError: Model type prism_hadamard_qwen35 not supported.` from `mlx_lm/utils.py`, `load_model`. The HTTP server starts and lists other cached models, but the pack does not load. No prompt could be sent.
- **Stop-and-ask (hard gate).** The runbook says a load error on `prism_hadamard_qwen35` stops this block and `sweep-bonsai2-mlx-mac`. Both stop. No sweep ran, and the server is stopped. Candidate answers for the owner: (a) drop the MLX blocks and close the run; (b) the owner names a stock-loader route for this model type. The publisher's own runtime in the pack (`runtime/runtime.py`) is not the stock server, so it is outside the runbook and I did not use it.
- Machine state: no server, wired 1.9 GB. Free disk 111 GB after the pack (8.6 GB).

## bonsai2-mlx-probe-mac, loader investigation (owner override, relayed by the coordinator 2026-09-22)

The coordinator relayed the owner's word: work the problem until the pack loads under MLX and answers the three prompts; record every route with versions and exact errors; never patch a file inside the pack or an installed package; a route that works but is not the stock server is a result, labelled as such.

Routes tried, in order. Venvs are under `~/.local/share/choose-a-local-llm/mlx-bonsai2/`; freezes in `results/`.

| route | versions | result |
|---|---|---|
| 1. stock `mlx_lm.server` | `mlx-lm` 0.31.3, `mlx` 0.32.0 (`venv`, `results/mlx-venv-freeze.txt`) | `ValueError: Model type prism_hadamard_qwen35 not supported.` from `mlx_lm/utils.py`, `load_model` |
| 2. the pack's own runtime, `artifact.load_model` | the pack's `requirements.txt` pins: `mlx` 0.32.0, `mlx-lm` 0.31.3, `mlx-vlm` 0.6.3, `transformers` 5.5.0, Python 3.14.7 (`venv-pack`, `results/mlx-venv-pack-freeze.txt`) | `ValueError: Unsupported packed model schema`. The loader accepts `schema_version` 1 only; the pack's `config.json` says 2. |
| 3. `mlx-vlm` built from `main` | `mlx-vlm` 0.7.1 at commit `1ab87fc7f3569a6daa123f4c353018dd781189dc`, `mlx` 0.32.2, `transformers` 5.17.0 (`venv-vlm`, `results/mlx-venv-vlm-freeze.txt`) | **Loads and answers all three prompts.** Its model registry has `prism_hadamard_qwen35` (pull request 2293, merged 2026-09-17). |

Not needed after route 3 worked, not tried: the publisher's demo build of the `PrismML-Eng/mlx` fork with `mlx-lm` 0.31.2, the third-party servers `mlx-serve` and `Rapid-MLX`, and LM Studio's MLX engine.

No file inside the pack or inside an installed package was edited.

Probe answers (temperature 0, `max_tokens` 256), in `results/mlx-probe-vlm.log` (`python -m mlx_vlm.generate`) and `results/mlx-probe-vlm-server.log` (through the server): `391`; a correct `reverse_string` function using `s[::-1]`, cut by the 256 limit in the server run; "The capital of France is **Paris**." All three are coherent and correct. The gate passes.

**The row is served by `mlx_vlm.server` from `mlx-vlm` main, not by the stock `mlx_lm.server`.** Command: `venv-vlm/bin/python -m mlx_vlm.server --host 127.0.0.1 --port 8081 --model <pack dir>`. Differences from the runbook's server: no `--prompt-cache-size` flag exists, and `/v1/cache/stats` reports the cache disabled, so the server may re-read the whole prompt at every step. The creep tool has no backend for this server; the sweep uses its `lmstudio` backend (streamed `/v1/chat/completions`, tool `e38c467`, pause 60 s, `STALL_S` 2400) with `MODEL` set to the pack path. Server log `results/server-mlx-vlm.log`. The pack carries the vision tower; the server was not given an image.

## Disk clean-up, 2026-09-19 (owner)

Owner approved the deletion. No partial download existed. Removed from the Hugging Face cache: `mlx-community/gemma-4-26b-a4b-it-4bit`, `mlx-community/Qwen3.6-35B-A3B-4bit`, `mlx-community/Qwen3.8-27B-4bit`, `AtomicChat/Qwen3.8-27B-GGUF`, and four files of `prism-ml/Ternary-Bonsai-27B-gguf` (`Q2_0`, `PQ2_0`, `dspark-bf16`, `dspark-Q4_1`). Free space on the data volume went from 13 GB to 96 GB. Free space read by `df -h` after the clean-up: 96Gi free, 90% used. The MLX pack download stays at the start of `bonsai2-mlx-probe-mac`; under 20 GB free at that point is stop and ask. The older bartowski Q4_K_M revision waits for the owner: `refs/main` points to `125a02a`, not to `f0eec4a`.

## Handing-over

**Status, 2026-09-20: the run waits for an owner decision.** `bonsai2-mlx-probe-mac` stopped at its gate: the stock `mlx_lm.server` 0.31.3 cannot load the pack at revision `3f926b415992eaa2ae9dd7b573706494d6bbf787` (`model.safetensors` 8595477990 bytes), error `Model type prism_hadamard_qwen35 not supported`. The owner chooses between dropping the MLX blocks and a loader route the owner names. The coordinator holds the run. Nothing runs on the Mac for this run.

Paused by the owner on 2026-09-19 and resumed 2026-09-20 (see `bonsai2-mlx-probe-mac`). Pause note: after `bonsai2-smoke-xhigh-mac` and before `bonsai2-mendel-blind-xhigh-mac` (`simulator(mendel-blind) bonsai-27b-ptq1 ptq1/xhigh`). The owner needs the Mac for other work. That block has no result, no worktree, no branch and no run file. It starts again from scratch when the owner says so.

- **Closed:** `machine-setup`, both ladder blocks, both sweep blocks, `bonsai2-calibrate-think-mac`, `bonsai2-budget-xhigh-mac`, `bonsai2-forced-rerun-mac`, `bonsai2-smoke-xhigh-mac` (pass).
- **Next, in order:** `bonsai2-mendel-blind-xhigh-mac`, `bonsai2-mlx-probe-mac` (MLX venv is installed, the pack is not downloaded; stop and ask if free disk is under 20 GB), `sweep-bonsai2-mlx-mac`, `retry-sweep`.
- **Serve for the blind row:** PTQ1_0, `-c 262144`, f16 KV, no drafter, no reasoning flag, window 159744, reserve 8192, level xhigh, pi id `bonsai2-27b-ptq1-mac`. Run `gh auth status` and `git stash clear` in `~/code/mendel-benchmark` first.
- **Machine state left behind:** no server, no watcher, no corpus server. Wired limit 25000. pi entry `bonsai2-27b-ptq1-mac` in `~/.pi/agent/models.json`, backup `~/.pi/agent/models.json.bak-run26`. Wakeup loop stopped.
- **Disk:** 4 repos and 4 Bonsai files removed by the owner. The older bartowski revision `125a02a` is still on disk; the owner has not chosen.
- **Evidence archive:** not run yet (`tools/archive-evidence.sh`).
