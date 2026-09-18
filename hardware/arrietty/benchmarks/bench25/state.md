# Run 25 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `vram_cap_mb` | 13811 | owner, 2026-09-17, 2.5 GB free of 16311 MiB |
| `serving_c` | 65536 | owner, 2026-09-17, fixed |
| `oblit_q4km_ngl` | 45 | `qwen38-oblit-q4km-offload-ladder`, 47 OOMs the cap |
| `oblit_q4km_clean` | none, all depths under 8 tok/s | `sweep-qwen38-oblit-q4km` |
| `oblit_q4km_window` | pending | `qwen38-oblit-q4km-smoke-medium` |
| `oblit_q4km_think_budget` | pending | `qwen38-oblit-q4km-calibrate-think` |
| `oblit_q4km_answer_budget` | pending | `qwen38-oblit-q4km-calibrate-think` |
| `oblit_q4km_max_tokens` | pending | `qwen38-oblit-q4km-calibrate-think` |
| `runwatch_silence` | pending | runner, raised for a slow offload server |
| `evalplus_python` | `/home/irae/.local/share/pipx/venvs/evalplus/bin/python` | pipx venv, already installed |
| `llama_server` | `0.4.0-dev (build 10809, commit 5266f24da)`, `v0.4.0-sm120` build | run 17 build, this machine |
| `disk_avail_before_dl` | 29G | `df -h ~`, before the download, file is 15.66 GiB |
| `mem_available_before_dl` | ~20.2 GB | `free -m`, before the download |
| `file_sha256` | `1f74330b211a8253c96f1bf586cba6eb56d37117c97ed9e6eec18c198a4e7fe5` | downloaded file, matches HF blob name |
| `file_size_bytes` | 16810705952 | matches the runbook's stated size |
| `vram_start_mb` | 638 MiB used / 16311 MiB total | `nvidia-smi`, after download |

Planning estimate, not a result: 16040 MiB of weights, 2176 MiB of KV
at 65536 tokens at q8_0, about 200 MiB of linear-attention state, about
600 MiB of compute buffers, against the cap of 13811 MiB, which gives
`-ngl 43` of 64 as the first load of the ladder.

## Why this run exists

This run measures the Q4_K_M build of the same binary that run 23
measures in Q3_K_M. It runs after run 23, whatever run 23 did (owner,
2026-09-17). Run 23's two ladder values, from `master`:
`oblit_q3km_c_q8` = 65536, `oblit_q3km_c_f16` = 32768. Run 23's
context gate **passed** (65536 ≥ 32768, pick q8_0) — it did not abort.
Run 23 finished its whole list; its Mendel smoke failed on a
tool-calling-format problem with the binary's chat template, not on
context or budget. So this run is the second point of the pair: the
larger quantization at the fixed 65536 window the card alone cannot
hold, not the answer to an abort.

## `machine-setup` — done

- `benchmarks/thinking-budget.py`, `benchmarks/calibrate.py`,
  `benchmarks/run_codegen_wrapper.py` all present, last touching
  commit `8b49c41`. `calibrate.py` writes `reasoning_len`. No merge
  needed.
- CUDA exports verified, `CUDA0` device present, `--reasoning-budget`
  and `--reasoning-budget-message` both print in `--help`.
- `EVALPLUS_PYTHON` set and working.
- Disk checked before the download: 29G available, well over the
  15.66 GiB file. `MemAvailable` before the download: ~20.2 GB.
- File downloaded (slow, ~30 MB/min, unauthenticated HF rate limit,
  about 20 minutes wall). sha256 and size match the runbook.
- Corpus server up on port 8089 from this worktree, hash verified.
- Result dirs created.

## `qwen38-oblit-q4km-offload-ladder` — done

Ladder in `results.md`: 43 pass, 51 fail, 47 fail, 45 pass.
`oblit_q4km_ngl` = 45 (13397 MiB at load, 13426 MiB under a real
~64K-token request, both under the 13811 cap). No gate fired — a
serving `-ngl` was found. Server stopped, VRAM back to baseline (624
MiB).

Deviation: the tool's own background-task memory tracker killed two
verification client attempts mid-request (host RAM pressure from the
offloaded layers), while the server itself stayed healthy both times.
The third attempt, run fully detached (`nohup` outside the tool's
tracking), completed cleanly. No effect on the ladder's result.

## `sweep-qwen38-oblit-q4km` — done, speed gate fires

Table in `results.md`. 4096 at 5.13 tok/s down to 64512 at 2.31 tok/s,
none reach the 8 tok/s floor. VRAM held at 13422-13424 MiB across the
sweep, well under the 13811 cap; the offload cost is speed, not
memory. Candidate answer sent to the coordinator: this build, at this
`-ngl` and window, is too slow for a full EvalPlus run to be worth its
wall time. Corpus server and model server stopped.

## Pause (owner word, 2026-09-18)

Finished at the `sweep-qwen38-oblit-q4km` block boundary, as asked.
No later block started; `retry-sweep` did not run.

Server stopped (`kill -9` on the `llama-server` PID), corpus server on
port 8089 stopped. `nvidia-smi` confirmed free: 622 MiB used, at the
session's own baseline (638 MiB at start).

**Next block on the list**: `qwen38-oblit-q4km-calibrate-think` — but
it is gated. The speed gate at the sweep found every depth under the
8 tok/s floor, so this block does not start until the coordinator
answers whether the run should still spend the hours a full EvalPlus
run costs at this speed.

**To resume the sweep's server** (if the coordinator says go on):

```bash
export PATH="$HOME/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/lib:$LD_LIBRARY_PATH"
llama-server -m "/home/irae/.cache/huggingface/hub/models--OBLITERATUS--Qwen3.8-27B-OBLITERATED/snapshots/a58c3b53b3ce71551eafde2ed5ec8df48e0f4ff8/Qwen3.8-27B-OBLITERATED-Q4_K_M.gguf" \
  --alias qwen3.8-27b-oblit-q4km --no-mmproj --parallel 1 \
  -ngl 45 --fit off -fa on -c 65536 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081 2>&1 \
  | tee hardware/arrietty/benchmarks/bench25/results/server-qwen38-oblit-q4km-calibrate-think.log
```

(no `--cache-ram 0` for this block, as the runbook's
`qwen38-oblit-q4km-calibrate-think` section says.) Then:

```bash
export EVALPLUS_PYTHON="/home/irae/.local/share/pipx/venvs/evalplus/bin/python"
CALIBRATION_DIR=hardware/arrietty/calibrations "$EVALPLUS_PYTHON" \
  benchmarks/calibrate.py qwen38-oblit-q4km-medium-think qwen3.8-27b-oblit-q4km \
  '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'
```

Machine state left behind: no `llama-server` process, no corpus
server, no watcher, no scoring process. The worktree and branch
`run25` stay as they are; this is a pause, not a close-out.

## Handing-over

`machine-setup`, `qwen38-oblit-q4km-offload-ladder`,
`sweep-qwen38-oblit-q4km` done. Paused at the sweep's close, per the
owner's word. `qwen38-oblit-q4km-calibrate-think` waits on the
coordinator's answer to the speed gate.
