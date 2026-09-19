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

## Disk clean-up, 2026-09-19 (owner)

Owner approved the deletion. No partial download existed. Removed from the Hugging Face cache: `mlx-community/gemma-4-26b-a4b-it-4bit`, `mlx-community/Qwen3.6-35B-A3B-4bit`, `mlx-community/Qwen3.8-27B-4bit`, `AtomicChat/Qwen3.8-27B-GGUF`, and four files of `prism-ml/Ternary-Bonsai-27B-gguf` (`Q2_0`, `PQ2_0`, `dspark-bf16`, `dspark-Q4_1`). Free space on the data volume went from 13 GB to 96 GB. The older bartowski Q4_K_M revision waits for the owner: `refs/main` points to `125a02a`, not to `f0eec4a`.

## Handing-over

The run has not started.
