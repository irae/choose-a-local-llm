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
