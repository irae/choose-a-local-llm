# Run 27 — results

One section per block: the ladder with the adapter loaded, the speed
curve beside run 24's unablated numbers for the same depths, the blind
agent row with its peak context and tool-call count, and the EvalPlus
group.

Every row of this run is served by the PrismML llama.cpp fork with a
rank-1 LoRA adapter applied at scale 1.0. The model file is unchanged
and stays byte-identical.

## `orca-ptq1-f16-ladder`

Config: PTQ1_0, f16 KV, LoRA scale 1.0, fork `prism-b10685-7dffb15`, `--fit off`. `-c` 139264 loads and serves a 138053-token request. VRAM 15375 MiB at load, 15385 MiB under the request, of 16311 MiB. **`orca_c` 139264**, equal to run 24's unablated ceiling. The adapter costs no window.

## `sweep-orca-ptq1-f16`

`llama-benchy`, `--pp 512 --tg 256 --runs 2`, `--cache-ram 0` for the measurement only, tokenizer `unsloth/Qwen3.8-27B`, `-c` 139264. Adapter served at id 0, scale 1.0.

| depth | run 27, adapter (tok/s) | run 24, no adapter (tok/s) | price of the adapter | prompt tok/s | VRAM MiB | MemAvailable MB |
|--:|--:|--:|--:|--:|--:|--:|
| 4096 | 40.76 | 42.1 | -1.34 (-3.2%) | 447.3 | 15385 | 18523 |
| 24576 | 36.18 | 37.3 | -1.12 (-3.0%) | 434.5 | 15372 | 18514 |
| 65536 | 29.15 | 30.1 | -0.95 (-3.2%) | 398.0 | 15543 | 18433 |
| 138240 | 22.03 | 22.4 | -0.37 (-1.7%) | 349.0 | 15543 | 18408 |

`orca_clean` 138240: the deepest depth at or above 8 tok/s. The runtime ablation costs about 3% of decode speed at shallow and middle depths and 1.7% at the deepest. No CUDA error in the server log. Files: `results/benchy-sweep-orca-ptq1-f16-lora1.md`, `.out.log`, `-vm.log`, `results/server-sweep-orca-ptq1-f16.log`.

## `orca-ptq1-f16-mendel-blind-xhigh`

simulator(mendel) blind, prompt v1.1, base tag `benchmark-blind-base`, level xhigh, alias `bonsai2-27b-ptq1-f16-orca`, branch `bonsai2-27b-ptq1-f16-orca-xhigh-issue-13`. Config: `prism-ml/Ternary-Bonsai-2-27B-gguf` `Ternary-Bonsai-2-27B-PTQ1_0.gguf` revision `6ed5e12bf84b7a63069882c91dd9e9218647d17b`; adapter `bonsai-abliterate-lora.gguf` sha256 `f1669534803d340a496015f5c45125f3437b4d13ec764f40e34488ce83967f42`, scale 1.0; fork `prism-b10685-7dffb15` commit `7dffb158d`; `-c` 139264, f16 KV, window 135168, reserve 8192, vram 16311 MiB. No smoke, and the row ran before any EvalPlus score of this config, so the 0.800 gate did not apply (owner, 2026-09-18).

| row | score | worst defect | tool calls | peak context | compactions | chore-typed commits | wall |
|---|--:|---|--:|--:|--:|--:|--|
| run 24, PTQ1_0 f16, no adapter | 82 | CRITICAL (trap A) | - | 127141 | 1 | 17 | - |
| **run 27, PTQ1_0 f16, LoRA scale 1.0** | **75** | medium (trap B missed) | 269 | 126798 of 135168 (93.8%) | 1 | 2 | 1 h 22 min |

Scored by Claude Fable 5.1 in a subagent, from the evidence pack, the session log and the worktree diff. Per-criterion points: 22 + 16 + 0 + 5 + 7 + 8 + 9 + 4 + 2.5 + 1.5 = 75, checked. Trap A not hit, trap C not hit, loop flag ok, 0 nudges, end reason complete, 8/8 libraries. Full breakdown: `results/score-orca-blind.md`. The 82 of run 24 had a CRITICAL trap A. This row hit no critical defect but scored 7 points lower on criteria 2 (trap B missed), 3 (no `pnpm install`, 0/8) and 5 (commit craft). Sampling applied by the server was not passed; the worker's `meta.json` holds the value.

## `orca-ptq1-f16-evalplus-budget-xhigh`

Config: PTQ1_0 f16 plus LoRA scale 1.0, `-c` 32768, `--reasoning-budget 30000 --reasoning-budget-message "Thinking budget reached. Give the final answer now."`, level xhigh, `EVALPLUS_MAX_NEW_TOKENS` 32048, temperature 0 from EvalPlus. The server applied `min_p` 0.05 (no sampling parameter passed). Full 164, watcher running. Wall: 02:08 to about 06:43 on 2026-09-19, about 4 h 34 min.

| row | base | plus | empty (from samples) | forced (from `finish.jsonl`) | think budget | answer budget | max_tokens |
|---|--:|--:|--:|--:|--:|--:|--:|
| run 24, PTQ1_0 f16, no adapter | 0.970 | 0.939 | - | - | - | - | - |
| **run 27, PTQ1_0 f16, LoRA scale 1.0** | **0.976** | **0.945** | 0/164 | 10/164 | 30000 | 2048 | 32048 |

Forced problems: HumanEval/32, /64, /76, /92, /99, /132, /137, /146, /157, /160. Three of them failed the tests: HumanEval/32, /99, /132 (see the forced re-run). The 0.800 gate for the agent row did not apply, because that row ran first. Files: `results/orca-ptq1-f16-budget-xhigh/`, `results/server-orca-ptq1-f16-budget-xhigh.log`.
