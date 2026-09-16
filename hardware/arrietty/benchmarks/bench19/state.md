# Run 19 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| vram_start_mb | 921 | `nvidia-smi`, session start |
| vram_total_mb | 16311 | `nvidia-smi` |
| disk_free_home | 5.3G | `df -h ~`, session start |
| evalplus_python | `/home/irae/.local/share/pipx/venvs/evalplus/bin/python` (Python 3.14.7) | pipx venv, EvalPlus 0.3.1 |

## `machine-setup`

- Installed EvalPlus 0.3.1 with pipx. `evalplus.codegen --help` runs
  clean.
- The dataset downloader (`evalplus.codegen`'s own fetch) never
  triggered in time to test; fetched
  `HumanEvalPlus-v0.1.10.jsonl` (164 rows) straight from
  `evalplus/humanevalplus_release` on GitHub instead, into
  `~/.cache/evalplus/`, per the runbook's fallback.
- `llama-server --version` prints no "cuda" string on this build (same
  as run 17); `llama-server --list-devices` confirms `CUDA0: NVIDIA
  GeForce RTX 5060 Ti`. Treat `--list-devices`, not `--version`, as
  the CUDA check on this build.
- Tool check: served `gemma-4-12b-nvfp4` (FreedomAISVR NVFP4 build,
  `-c 32768`, f16 KV, thinking off), ran `calibrate.py` into
  `results/calibration-toolcheck.json`. Ten rows, `resolved_reasoning_effort`
  null on every row, consistent with the thinking-off request. Pass.
  Server stopped, vram back to 1036 MiB (near the 921 MiB start).

Deviation: none that blocks the run.

## `qwen38-ista-evalplus-xhigh` — running

`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, MTP draft n-max 2, one
slot, q8_0 KV, ctx 32768 served, wired (vram) 14583 MiB. Served with
`--spec-type draft-mtp --spec-draft-n-max 2`.

Calibration `qwen38-ista-xhigh`, xhigh reasoning: 10/10 rows, 2 `length`
stops (`HumanEval/32`, `HumanEval/99`, both hit the 30000 cap, empty).
Non-converging pattern (`docs/methodology/evalplus.md`, calibration step
3): budget is not the observed-max × 1.5 formula. Longest SUCCESSFUL
completion is `HumanEval/145` at 20324 tokens. `qwen38-ista_budget` =
20500 (just above 20324), source: calibration-qwen38-ista-xhigh.json,
non-converging rule. Expect a real empty rate near 20% (2/10 in
calibration) and do not chase it with a bigger budget.

Deviation: none — non-converging calibration handled per the runbook's
own rule, not a stop-and-ask condition.

**Parts (owner rule, 2026-09-15, wall = sum of parts, gaps excluded):**

| part | arm | start (UTC) | end (UTC) | reason |
|---|---|---|---|---|
| 1 | drafter | 2026-09-15T11:52:37Z | 2026-09-15T12:35:44Z | crash, CUDA launch timeout |
| 2 | drafter | 2026-09-15T12:51:43Z | 2026-09-15T12:59:24Z | crash, CUDA launch timeout (Xid 8) |
| 3 | no-drafter | 2026-09-15T13:16:39Z | 2026-09-15T14:29:48Z | switched back to drafter on owner word (66/164 solved, kept) |
| 4a | drafter, codegen | 2026-09-15T14:29:48Z | 2026-09-15T16:02:17Z | finished, 164/164, no further crash |
| 4b | drafter, evaluate | 2026-09-15T19:58:07Z | 2026-09-15T19:59:18Z | finished |

Wall = sum of parts 1+2+3+4a+4b = 43.1 + 7.7 + 73.2 + 92.5 + 1.2 =
**217.6 min**. The gap between 4a and 4b (16:02–19:58) does not count:
`run-humaneval.sh`'s bash wrapper (which chains codegen → evaluate) had
been killed during the part-2 crash recovery; only its python codegen
child survived and finished on its own with nothing left alive to run
the evaluate step. Ran `evalplus.evaluate` by hand once codegen's
164/164 was noticed. No further crash, no data lost — the gap is agent
latency, not compute, and is excluded the same way a crash gap is.

Owner word (2026-09-15, via chat, not the coordinator): keep retrying
the drafter arm on every crash, do not fall back to no-drafter
permanently. Problems already solved on the no-drafter part (66/164)
are kept — speculative decoding never changes the output at
temperature 0 (`docs/methodology/evalplus.md`), so mixing arms across
parts of the same run is valid. `run-humaneval.sh`'s resume-from-jsonl
behavior carries every part forward regardless of arm.

The full run started with the watcher; after 7/164 problems the watcher
exited 42 (`SERVER DEAD: two probes did not return, each after 600s
without output growth`), the server log showing `CUDA error: the launch
timed out and was terminated`. Killed the stalled `run-humaneval.sh`
wrapper, restarted the server (same config), verified it loads and
serves. The underlying `run_codegen_wrapper.py` child process had
survived the kill and had already resumed against the restarted
server before I checked — no manual resume needed, `run-humaneval.sh`'s
resume-from-jsonl behavior held. Started a fresh watcher
(`server-qwen38-ista-retry1.log`). Recoverable failure, retried inside
the block per the runbook.

**Second CUDA timeout, still 2/164, switch to fallback arm.** The
watcher exited 42 again a few minutes later, same signature. Confirmed
with `journalctl -k`: `NVRM: krcWatchdog: RC watchdog: GPU is probably
locked! Notify Timeout Seconds: 7` then `NVRM: Xid (PCI:0000:01:00): 8,
pid=1349049, name=llama-server` — the same driver-watchdog event run
17 saw once (`bench17/state.md`, `diagnose-crash` finding), now twice
on this drafter config. Per the runbook's own rule (a CUDA death inside
the block is a switch to the fallback arm), restarted **without the
drafter** (`no drafter`, dropping `--spec-type draft-mtp
--spec-draft-n-max 2`). Loads clean, vram 13638 MiB, `run_codegen_wrapper.py`
resumed against it immediately. Fresh watcher
(`server-qwen38-ista-retry2-nodraft.log`).

Deviation: two CUDA launch-timeout crashes (Xid 8) on the drafter arm;
switched to the fallback arm inside the block per the runbook. Watching
for a repeat on no-drafter.

### `qwen38-ista-evalplus-xhigh` close

`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, MTP draft n-max 2
(parts 1, 2, 4) / no drafter (part 3), one slot, q8_0 KV, ctx 32768,
budget 20500. No further crash after part 4 restarted the drafter arm
on owner word.

| metric | value |
|---|--:|
| HumanEval base | 0.945 |
| HumanEval plus | 0.909 |
| completion rate | 100% |
| empty | 0/164 |
| wall | 217.6 min (parts 1+2+3+4a+4b, gaps excluded) |

Files: `results/qwen38-ista-evalplus-xhigh/humaneval/`,
`results/server-qwen38-ista*.log`.
Deviation: two CUDA watchdog crashes on the drafter arm (parts 1-2),
recovered per the runbook; switched to no-drafter (part 3, 66/164
solved) then back to drafter on owner word (part 4, finished clean,
0/164 empty on any arm — drafter never changed the score, as expected
at temperature 0).

## Handing over

`machine-setup` and `qwen38-ista-evalplus-xhigh` done: base 0.945,
plus 0.909, 0/164 empty, wall 217.6 min. On to
`qwen38-iq3s-evalplus-xhigh`, no-drafter from the start per the
coordinator's owner-approved rule (2026-09-15), `-c 32768`, q8_0 KV,
2048 MiB free-VRAM floor after load.

## `qwen38-iq3s-evalplus-xhigh` — running

`unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S`, no drafter (owner rule
2026-09-15), one slot, q8_0 KV, ctx 32768 served, vram 13470 MiB, 2417
MiB free after load (above the 2048 MiB floor). Model file already in
the default `hf` cache (migrated earlier this session):
`~/.cache/huggingface/hub/models--unsloth--Qwen3.8-27B-GGUF/snapshots/4ca720788d1e01f1bff70c033e0d0028fd02e502/`.

Calibration `qwen38-iq3s-xhigh`, xhigh reasoning: 10/10 rows, 2
`length` stops (`HumanEval/32`, `HumanEval/99`, both hit the 30000 cap,
empty) — same non-converging pattern as the ista build. Longest
successful completion is `HumanEval/145` at 18907 tokens.
`qwen38-iq3s_budget` = 19000 (just above 18907), source:
calibration-qwen38-iq3s-xhigh.json, non-converging rule.

Deviation: none — handled per the same runbook rule as the ista block.

### `qwen38-iq3s-evalplus-xhigh` close

`unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S`, no drafter throughout, one slot,
q8_0 KV, ctx 32768, budget 19000. One part, no crash, watcher clean
start to close: 2026-09-15T20:02:29Z to 2026-09-16T00:52:07Z.

| metric | value |
|---|--:|
| HumanEval base | 0.957 |
| HumanEval plus | 0.921 |
| completion rate | 100% |
| empty | 0/164 |
| wall | 289.6 min (one part, no crash) |

Files: `results/qwen38-iq3s-evalplus-xhigh/humaneval/`,
`results/server-qwen38-iq3s.log`.
Deviation: none.

## `qwen36-q4kxl-evalplus-on` — running

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, MTP draft n-max 2,
`--n-cpu-moe 21`, one slot, q8_0 KV, ctx 32768 served, vram 14066 MiB,
1770 MiB free after load. Model file already in the default `hf`
cache (migrated earlier this session). System under host memory
pressure with this config (`--n-cpu-moe 21` puts 21 experts' worth of
weights in host RAM): ~1.1-1.5 GB free, 10-11 GB swap in use, stable
(not growing) through the calibration. Background wait wrappers
(`run_in_background`) were repeatedly reaped by the harness's own low-
memory guard during this block; the actual llama-server and
calibration processes were unaffected — checked with `ps`/`pgrep`
directly at each wakeup instead.

Calibration `qwen36-q4kxl-on`, thinking on: 10/10 rows, 0 `length`
stops — converges normally, unlike both Qwen3.8 builds. Standard
formula: max completion 16103 × 1.5 = 24154 ≥ floor 8192.
`qwen36-q4kxl_budget` = 24154.

Deviation: harness background-wait wrappers reaped under host memory
pressure (not the run's own processes); worked around by polling
directly. Watching swap for growth during the full run per the
checklist.

### `qwen36-q4kxl-evalplus-on` close

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, MTP draft n-max 2,
`--n-cpu-moe 21`, one slot, q8_0 KV, ctx 32768, budget 24154. One
part, no crash: 2026-09-16T01:03:04Z to 2026-09-16T04:15:05Z. Swap
stayed flat through the run, no growth.

| metric | value |
|---|--:|
| HumanEval base | 0.945 |
| HumanEval plus | 0.902 |
| completion rate | 100% |
| empty | 0/164 |
| wall | 192.0 min (one part, no crash) |

Files: `results/qwen36-q4kxl-evalplus-on/humaneval/`,
`results/server-qwen36-q4kxl.log`.
Deviation: none.

## `gemma26-nvfp4-evalplus-on` — running

`catlilface/Gemma-4-26B-A4B-NVFP4-GGUF:Q8`, `--n-cpu-moe 7`, one slot,
f16 KV, ctx 32768 served, vram 14432 MiB, 1454 MiB free after load
(above this block's 1200 MiB floor).

Calibration `gemma26-nvfp4-on`, thinking on: 10/10 rows, 2 `length`
stops (`HumanEval/124`, `HumanEval/145`, both hit the 30000 cap,
empty) — non-converging, same pattern as both Qwen3.8 builds. Longest
successful completion `HumanEval/32` at 12241 tokens.
`gemma26-nvfp4_budget` = 12500 (just above 12241), non-converging rule.

Deviation: none — handled per the same runbook rule as the ista/iq3s
blocks.

### `gemma26-nvfp4-evalplus-on` close

`catlilface/Gemma-4-26B-A4B-NVFP4-GGUF:Q8`, `--n-cpu-moe 7`, one slot,
f16 KV, ctx 32768, budget 12500. One part, no crash:
2026-09-16T04:36:15Z to 2026-09-16T08:11:33Z.

| metric | value |
|---|--:|
| HumanEval base | 0.909 |
| HumanEval plus | 0.878 |
| completion rate | 100% |
| empty | 0/164 |
| wall | 215.3 min (one part, no crash) |

Files: `results/gemma26-nvfp4-evalplus-on/humaneval/`,
`results/server-gemma26-nvfp4.log`.
Deviation: none.

## Handing over

`machine-setup`, `qwen38-ista-evalplus-xhigh` (0.945/0.909, 0/164
empty), `qwen38-iq3s-evalplus-xhigh` (0.957/0.921, 0/164 empty),
`qwen36-q4kxl-evalplus-on` (0.945/0.902, 0/164 empty) and
`gemma26-nvfp4-evalplus-on` (0.909/0.878, 0/164 empty) done. On to
`gemma12-nvfp4-evalplus-off` next (the two Gemma-12B NVFP4 blocks
share one server, off then on).
