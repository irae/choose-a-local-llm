# Run 28 — state

One section per block, in the order the runbook lists, as it happens.

## `machine-setup`

- 2026-09-19: `vram_start_mb` 837 (desktop only). `MemAvailable` 19172104 kB. `df -h ~`: 13 GB free of 231 GB (95%). `gh auth status` passes. No `llama-server` running.
- Stock binary: run 19's CUDA `llama-server`, `CUDA0` found, `--reasoning-budget` and `--reasoning-budget-message` listed.
- Fork binary (`prism-b10685-7dffb15`): flags listed. It needs `LD_LIBRARY_PATH` with its own directory and run 17's `lib` directory (`libcudart.so.12`).
- `EVALPLUS_PYTHON` = `/home/irae/.local/share/pipx/venvs/evalplus/bin/python`.
- No download needed for the first block. Disk is low: 13 GB free.

## `fast-qwen38-iq3s-xhigh`

- Serve: row command with `-c 32768` and `$FAST_FLAGS`, run 19's binary. `hf download` on this machine prints `path=` before the path; every serve command uses `hf download --quiet`.
- `nvidia-smi` at load: 13093 MiB used of 16311 (desktop included, `vram_start_mb` 837). After the probe: 13101 MiB.
- Probe (xhigh, palindrome prompt): `finish_reason` stop, 245 completion tokens, `reasoning_content` present, `content` 465 characters, no error in the server log. It converged early, so the budget message did not show. The response has no `resolved_reasoning_effort` field on this binary.
- Part 1 start 2026-09-20T02:48:08Z
- Part 1: 2026-09-20T02:48:08Z to about 05:56Z (finish, evaluate included). No crash, no restart. Wall about 188 min; the request walls in `finish.jsonl` sum to 177.1 min.
- Result: base 0.963, plus 0.921. Empty 0/164, forced 8/164, no answer on `length`.

## `fast-bonsai2-ptq1-f16-xhigh`

- Serve: fork `prism-b10685-7dffb15` (`LD_LIBRARY_PATH` with run 17's `lib`), row command with `-c 32768`, f16 KV, `$FAST_FLAGS`.
- `nvidia-smi` at load: 8803 MiB; after the probe 8809 MiB (desktop included).
- Probe (xhigh, HumanEval/10): `finish_reason` stop, 8369 completion tokens, reasoning present, `content` 620 characters, reasoning tail ends with the budget message, no error in the log.
- Splice from `bench24/results/bonsai2-ptq1-f16-evalplus-budget-xhigh`: kept 152, to generate 12 (HumanEval/10 32 39 47 76 80 95 99 116 132 137 145).
- Part 1 start 2026-09-20T06:01:01Z
- Part 1: 2026-09-20T06:01:01Z to 06:45Z, no crash. Own wall about 44 min (requests sum to 40.4 min). The 152 kept problems cost 81.1 min in the source. Wall about 125 min.
- Result: base 0.976, plus 0.945. Empty 0/164, forced 12/164 (all 12 regenerated problems), none on `length`.

## `fast-bonsai2-pq2-f16-xhigh`

- Serve: fork, row command with `-c 32768`, f16 KV, `$FAST_FLAGS` (helper `~/.local/share/choose-a-local-llm/run28-serve-fork.sh`).
- `nvidia-smi` at load: 9947 MiB; after the probe 9951 MiB (desktop included).
- Probe (xhigh, HumanEval/10): stop, 6357 completion tokens, reasoning present, `content` 621 characters, no error in the log. It converged before 8192, so no budget message shows.
- Splice from `bench24/results/bonsai2-pq2-f16-evalplus-budget-xhigh`: kept 152, to generate 12.
- Part 1 start 2026-09-20T06:48:40Z
- Part 1: 2026-09-20T06:48:40Z to about 07:33Z, no crash. Own wall about 44 min (requests 39.6 min). The 152 kept problems cost 77.3 min in the source. Wall about 121 min.
- Result: base 0.982, plus 0.945. Empty 0/164, forced 12/164.
- Finding: HumanEval/64 was forced (a `yY` loop in the thinking) and its answer then ran to `length` at 16384 tokens. It holds code (9104 characters), so it is not empty. It is a `budget` end after a forced answer.

## `fast-bonsai2-ptq1-xhigh`

- Serve: fork, row command with `-c 32768`, q8_0 KV, `$FAST_FLAGS`.
- `nvidia-smi` at load: 7927 MiB; after the probe 7933 MiB (desktop included).
- Probe (xhigh, HumanEval/10): stop, 1636 completion tokens, reasoning present, `content` 600 characters, no error. It converged early, so no budget message shows.
- Splice from `bench24/results/bonsai2-ptq1-evalplus-budget-xhigh`: kept 148, to generate 16.
- Part 1 start 2026-09-20T07:34:46Z
- Part 1: 2026-09-20T07:34:46Z to about 08:38Z (last request 08:32:53Z, evaluate after), no crash. Own wall about 64 min (requests 58.1 min). The 148 kept problems cost 75.8 min in the source. Wall about 140 min.
- Result: base 0.982, plus 0.945. Empty 0/164, forced 16/164.
- Finding: HumanEval/64 again ended on `length` at 16384 after a forced answer (same problem as in `fast-bonsai2-pq2-f16-xhigh`).
- Deviation: the block ended at about 08:38Z and I closed it at 13:32Z. The wakeups did not fire between 08:00Z and 13:30Z (the session login interrupted them). The card sat idle about 5 hours.

## `fast-bonsai2-pq2-xhigh`

- Serve: fork, row command with `-c 32768`, q8_0 KV, `$FAST_FLAGS`.
- `nvidia-smi` at load: 9060 MiB; after the probe 9064 MiB (desktop included).
- Probe (xhigh, HumanEval/10): stop, 8366 completion tokens, reasoning present, `content` 626 characters, reasoning tail ends with the budget message, no error.
- Splice from `bench24/results/bonsai2-pq2-budget-xhigh`: kept 152, to generate 12.
- Part 1 start 2026-09-20T13:36:08Z
- Part 1: 2026-09-20T13:36:08Z to about 14:18Z, no crash. Own wall about 42 min (requests 40.3 min). The 152 kept problems cost 76.7 min in the source. Wall about 119 min.
- Result: base 0.988, plus 0.945. Empty 0/164, forced 12/164.
- Finding: HumanEval/64 ended on `length` at 16384 after a forced answer here too. It now does so on all three PQ2/PTQ1 rows that generated it.

## `fast-bonsai2-ptq1-f16-orca-xhigh`

- Serve: fork, PTQ1_0 with the adapter, f16 KV, `-c 32768`, `$FAST_FLAGS`, LoRA scale 1.0. Deviation: the row command's `hf download Continuum-AI-Corp/OrcaBonsai-27B-Uncensored ...` fails (repository not found). The adapter is the git clone `/home/irae/code/OrcaBonsai-27B-Uncensored/gguf/bonsai-abliterate-lora.gguf` at commit `947a80c`, the file run 27 served. A first start with an empty adapter path failed at once and I removed its result directory.
- `nvidia-smi` at load: 8824 MiB; after the probe 8830 MiB (desktop included).
- Probe (xhigh, HumanEval/32): stop, 8786 completion tokens, reasoning present, `content` 1655 characters, reasoning tail ends with the budget message, no error.
- Splice from `bench27/results/orca-ptq1-f16-budget-xhigh`: kept 146, to generate 18.
- Part 1 start 2026-09-20T14:23:08Z
- Part 1: 2026-09-20T14:23:08Z to about 15:33Z (last request 15:29:21Z, evaluate after), no crash. Own wall about 70 min (requests 66.1 min). The 146 kept problems cost 82.3 min in the source. Wall about 152 min.
- Result: base 0.976, plus 0.945. Empty 0/164, forced 18/164.
- Finding: HumanEval/64 ended on `length` at 16384 after a forced answer here too, the third ternary row where it does so.

## `fast-gemma26-nvfp4-on`

- Serve: run 19's binary, row command with `-c 32768`, f16 KV, `--n-cpu-moe 7`, no drafter (the row has none), `$FAST_FLAGS`.
- `nvidia-smi` at load: 14016 MiB; after the probe 14064 MiB (desktop included).
- Probe (`enable_thinking` true, HumanEval/0): stop, 820 completion tokens, reasoning present, `content` 542 characters, no error. It converged early, so no budget message shows.
- No splice source: all 164 generated.
- Part 1 start 2026-09-20T15:50:33Z
- Part 1: 2026-09-20T15:50:33Z to about 18:25Z, no crash. Wall about 154 min (requests sum to 153.6 min). No splice.
- Deviation: the `evaluate` step of `run-humaneval.sh` failed (`No completion or solution found in sample`). Its `find "$DIR" -name "*.jsonl" ! -name "*.raw.jsonl" | head -1` picked `finish.jsonl` instead of the samples file; the earlier blocks got the right file by find order. I ran `evalplus.evaluate` by hand on the samples file, and the score below is from that run, saved in `evaluate.log`. Tool bug for the coordinator: the `find` must be limited to `humaneval/`.
- Result: base 0.988, plus 0.951. Empty 0/164, forced 19/164, none on `length`.

## `fast-qwen36-q4kxl-on`

- Skipped for now (blocked on disk). `unsloth/Qwen3.6-35B-A3B-MTP-GGUF` `Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` is not in the `hf` cache (only the 20 MB tokenizer repo is). The file is about 22 GB; `df -h ~` shows 13 GB free (95% used). Sizes in the cache: OBLITERATUS 29 GB (row needs one file), Gemma-26B 15 GB and Ternary-Bonsai 13 GB and Qwen3.8 IQ3_S 12 GB (their blocks are done), ISTA 12 GB (not in this run). I delete nothing without the coordinator's word. The block moves to `retry-sweep`.

## Tool bug: `run-humaneval.sh` picks `finish.jsonl` as the samples file

- Line: `SAMPLES=$(find "$DIR" -name "*.jsonl" ! -name "*.raw.jsonl" | head -1)`. `$DIR` holds `finish.jsonl` beside `humaneval/`, so `head -1` can return `finish.jsonl`, and `evalplus.evaluate` stops with `AssertionError: No completion or solution found in sample!`. It hit `fast-gemma26-nvfp4-on` (order of `find` varies); the other blocks of this run got the right file.
- The command I ran by hand (from the repo root, run 28 worktree, with the run 28 environment sourced), output to `evaluate.log`:
  `evalplus.evaluate --dataset humaneval --samples "$PWD/hardware/arrietty/benchmarks/bench28/results/fast-gemma26-nvfp4-on/humaneval/gemma-4-26b-a4b-nvfp4_openai_temp_0.0.jsonl" 2>&1 | tee "$PWD/hardware/arrietty/benchmarks/bench28/results/fast-gemma26-nvfp4-on/evaluate.log"`
- Suggested fix: `find "$DIR/humaneval" -name "*.jsonl" ! -name "*.raw.jsonl" | head -1`.

## `fast-gemma12-nvfp4-on`

- Serve: run 19's binary, row command with `-c 32768`, f16 KV, no drafter, `$FAST_FLAGS`. The file is `gemma-4-12b-it-nvfp4.gguf` (the row command's name).
- `nvidia-smi` at load: 8768 MiB; after the probe 8774 MiB (desktop included).
- Probe (`enable_thinking` true, HumanEval/1): stop, 2467 completion tokens, reasoning present, `content` 1418 characters, no error. It converged early, so no budget message shows.
- Splice from `bench21/results/gemma12-nvfp4-budget-on`: kept 119, to generate 45 (planning count 45).
- Part 1 start 2026-09-20T18:39:54Z

## `fast-qwen38-oblit-q3km-medium`

- Dropped on the owner's word, relayed by the coordinator on 2026-09-20: the abliterated Qwen3.8 model is retired. The block never starts. The coordinator deletes its two cache files. Order left: `fast-gemma12-nvfp4-on`, `fast-gemma12-q4kxl-on`, `retry-sweep` (with `fast-qwen36-q4kxl-on` when the coordinator says so).
- Part 1: 2026-09-20T18:39:54Z to about 20:55Z (last request 20:53:16Z), no crash. Own wall about 135 min (requests 133.3 min). The 119 kept problems cost 76.2 min in the source. Wall about 211 min.
- Result: base 0.976, plus 0.951. Empty 0/164, forced 44/164.
- Finding: HumanEval/145 ended on `length` at 16384 after a forced answer. It holds code, so it is not empty.

## `fast-gemma12-q4kxl-on`

- Serve: run 19's binary, row command with `-c 32768`, f16 KV, no drafter, `$FAST_FLAGS`.
- `nvidia-smi` at load: 9141 MiB; after the probe 9147 MiB (desktop included).
- Probe (`enable_thinking` true, HumanEval/0): stop, 1155 completion tokens, reasoning present, `content` 829 characters, no error. It converged early, so no budget message shows.
- No splice source: all 164 generated.
- Part 1 start 2026-09-20T21:06:17Z
- Part 1: 2026-09-20T21:06:17Z to about 00:25Z (last request 2026-09-21T00:23:39Z), no crash. Wall about 198 min (requests sum to 197.3 min). No splice.
- Deviation: the `find` bug of `run-humaneval.sh` (see "Tool bug" above) hit again. Score from `evalplus.evaluate --dataset humaneval --samples "$PWD/hardware/arrietty/benchmarks/bench28/results/fast-gemma12-q4kxl-on/humaneval/gemma-4-12b-q4kxl_openai_temp_0.0.jsonl"`, saved in `evaluate.log`.
- Result: base 0.988, plus 0.963. Empty 0/164, forced 34/164, none on `length`.

## `retry-sweep`

- Only `fast-qwen36-q4kxl-on` is left. It waits on the owner's word for the 22.9 GB download (the file is not on disk; `df -h ~` now shows 41 GB free after the coordinator deleted the retired abliterated files). Nothing else waited on a human.

## Handing over

- What ran: `machine-setup` and ten blocks in fast mode, all with the fast flags and `-c 32768`: `fast-qwen38-iq3s-xhigh` (0.963/0.921), `fast-bonsai2-ptq1-f16-xhigh` (0.976/0.945), `fast-bonsai2-pq2-f16-xhigh` (0.982/0.945), `fast-bonsai2-ptq1-xhigh` (0.982/0.945), `fast-bonsai2-pq2-xhigh` (0.988/0.945), `fast-bonsai2-ptq1-f16-orca-xhigh` (0.976/0.945), `fast-gemma26-nvfp4-on` (0.988/0.951), `fast-gemma12-nvfp4-on` (0.976/0.951), `fast-gemma12-q4kxl-on` (0.988/0.963). Empty was 0/164 on every row. Details are in `results.md`.
- Not run: `fast-qwen36-q4kxl-on` (file deleted on 2026-09-17, waits for the owner) and `fast-qwen38-oblit-q3km-medium` (dropped, the model is retired).
- What went wrong and why: (1) `run-humaneval.sh` picks `finish.jsonl` as the samples file when `find` lists it first; it hit two blocks (`fast-gemma26-nvfp4-on`, `fast-gemma12-q4kxl-on`) and I ran `evalplus.evaluate` by hand. (2) The row command of the Orca row downloads its adapter with `hf`, which fails; the adapter is the clone at `/home/irae/code/OrcaBonsai-27B-Uncensored` (commit `947a80c`). (3) HumanEval/64 ended on `length` after a forced answer on the three ternary PQ2 and PTQ1 rows that generated it, and HumanEval/145 did on `fast-gemma12-nvfp4-on`; all hold code. (4) The card sat idle about 5 hours after `fast-bonsai2-ptq1-xhigh` because the wakeups did not fire.
- Machine state: no `llama-server`, no watcher, VRAM 826 MiB, port 8081 free. Disk 41 GB free. Helper scripts `run28-env.sh`, `run28-serve-fork.sh`, `run28-serve-stock.sh` and `run28-block.sh` are in `~/.local/share/choose-a-local-llm/`.
- Evidence: `tools/archive-evidence.sh` found nothing to archive (it copies pi session logs; EvalPlus results, `finish.jsonl` and `evaluate.log` are committed under `results/`).
