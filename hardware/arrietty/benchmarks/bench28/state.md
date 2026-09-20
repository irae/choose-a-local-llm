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
