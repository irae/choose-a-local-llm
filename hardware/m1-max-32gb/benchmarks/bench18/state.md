# Run 18 — state

The run's log. The runner writes the medium form of every block here
at block close (`docs/methodology/status-lines.md`), and every value a
block assigns, one line per value, with its source.

## Values

- preflight start: wired 1954 MB, free 19818 MB, swap used 179 MB. Balloon needed (source: `tools/preflight.sh`, 2026-09-14).
- `qwen38_unsloth_path`: `/Users/irae/.cache/huggingface/hub/models--unsloth--Qwen3.8-27B-GGUF/snapshots/4ca720788d1e01f1bff70c033e0d0028fd02e502/Qwen3.8-27B-UD-IQ3_S.gguf`
- `qwen38_unsloth_rev`: `4ca720788d1e01f1bff70c033e0d0028fd02e502` (matches the AGENT.md expected revision)
- `qwen38_unsloth_sha256`: `d847e2c1e4aa276e4b7b8e9ad7628050e61e165d49ab995407bc36677a6f3864` (matches the Linux box's file exactly, same file)
- `creep_tool_rev`: `e38c467` (`local-llm-eval-tools`, already up to date)
- `benchy_version`: `llama-benchy 0.4.0` (pipx, Python 3.14.7), read from run 16's state at `hardware/m1-max-32gb/research/run4/state.md`
- `benchy_corpus`: `results/corpus-mendel-js.txt`, 152099 Qwen tokens, sha256 `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`, served at `http://127.0.0.1:8089/corpus-mendel-js.txt`
- `benchy_invocation`: as in run 16's state, `--book-url http://127.0.0.1:8089/corpus-mendel-js.txt --pp 512 --tg 256 --runs 2`, server flag `--cache-ram 0` for measurement runs
- pi entry `qwen3.8-27b-iq3s` added to `~/.pi/agent/models.json`, provider `llama`, copied from `qwen3.8-27b-ista` (contextWindow 147456 is a placeholder). Verified with `pi --list-models | grep qwen3.8`.
- Every Qwen3.8 entry's `thinkingLevelMap` set to `{off: null, minimal: null, low: "low", medium: "medium", high: "medium", xhigh: "xhigh", max: "xhigh"}`. Every other reasoning entry of provider `llama` remapped down by the same rule (binary off/high models: off/minimal/low/medium → off, high/xhigh/max → high). Entries with no `thinkingLevelMap` (`qwen3.6-27b`, `gemma-4-12b-2x`, `bonsai-prism`, `bonsai-prism-f16`) left untouched. Before/after snapshots: `/tmp/pi_map_before.json`, `/tmp/pi_map_after.json` (not committed, local only).
- `~/code/mendel-benchmark` fast-forwarded to `origin/benchmark` (fe692ec → 0ab06c6). `gh auth status` passes (account irae).
- Note: origin carries a remote branch `qwen3.8-27b-iq3s-xhigh-guided-v3-issue-13-interrupted1`, meaning a prior attempt at this exact model's guided row was interrupted. Not investigated yet; the runbook's own worker naming picks a fresh branch when none exists, so this is only a flag for later, not a blocker.
- `qwen38_unsloth_c`: 188416 (largest passing rung, ladder).
- `qwen38_unsloth_wired_load`: 25911 MB (wired at load, rung 188416).
- Deviation, noted as it happened: rung 180224 passed the real-request check with wired 25344 MB, above the configured `iogpu.wired_limit_mb` (25000). The sysctl gates the process's GPU-accelerator resident view, not overall wired, so a pass above 25000 total wired is not itself an error signature; the ladder rule (real request served, no Metal OOM in the log) still applied. Flagged for the owner, not a stop condition.

## Blocks

### machine-setup

The model file loaded clean through llama-server with no `Insufficient Memory`, no Metal OOM, no 500 (log `results/server-download.log`). Server stopped after load. Sweep tool, benchy values, pi entry and thinking maps, and the mendel-benchmark repo are all in place; `gh auth status` passes.
Deviation: none.

### ladder-qwen38-unsloth

`unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S` rev `4ca7207`, one slot, f16 KV, wired limit 25000. 4 loads of 6 allowed.

| rung | result | wired MB | note |
|--:|---|--:|---|
| 163840 | pass | 24251 | clean, no error |
| 180224 | pass | 25344 | clean, no error (wired above the 25000 sysctl, see deviation) |
| 196608 | fail | — | Metal OOM during load (`kIOGPUCommandBufferCallbackErrorOutOfMemory`), even though the server later logged "model loaded" and "listening" |
| 188416 | pass | 25911 | bisected between 180224 (pass) and 196608 (fail); clean, no error |

`qwen38_unsloth_c` = 188416, `qwen38_unsloth_wired_load` = 25911 MB.
Files: `results/server-ladder-163840.log`, `results/server-ladder-180224.log`, `results/server-ladder-196608.log`, `results/server-ladder-188416.log`.
Deviation: wired at the two largest passing rungs (25344, 25911 MB) is above the 25000 sysctl wired limit; see the Values section.

### creep-qwen38-unsloth-nodrafter

`unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S` rev `4ca7207`, no drafter, `-c 188416`, one slot, f16 KV, wired limit 25000. Tool `e38c467`. `STOP: below 8 tok/s at depth 163858`, a real speed floor, not a dead server: `swap_delta_mb` reads 0 on every row.

`qwen38_unsloth_clean` = 147478 (8.17 tok/s, the deepest step at or above 8 tok/s before the STOP).
`qwen38_unsloth_gated` = speed.

Mac numbers to read against, the ISTA file at the same settings: 14.1 at 4K, 8.3 at 147478, speed gated. This build: 13.70 at 4K, 8.17 at 147478 — close, slightly slower.
Files: `results/creep-qwen38-unsloth-nodrafter.tsv`, `results/server-creep-nodrafter.log`.
Deviation: none.

### sweep-qwen38-unsloth (drafter `-c` search)

n-max 3 at `-c 4096`: wired at load 14409 MB. Estimate: `(188416 - (25911-14409)/0.0671*1000)` rounded down to a multiple of 8192 = 16384.
4 loads for the search (the estimate probe, then bisection):

| `-c` | result | wired MB |
|--:|---|--:|
| 16384 | pass | 15298 |
| 98304 | pass | 21542 |
| 139264 | pass | 24680 |

Budget exhausted at 4 loads (estimate probe + 3 bisection loads), all passing; the search never hit a fail to bisect against. `qwen38_unsloth_mtp_c` = 139264 (the last, deepest passing rung tried).
Files: `results/server-sweep-mtpc-probe-4096.log`, `results/server-sweep-mtpc-probe-16384.log`, `results/server-sweep-mtpc-probe-98304.log`, `results/server-sweep-mtpc-probe-139264.log`.
Deviation: the search budget (4 loads) never found a fail, so 139264 is the deepest of the loads tried, not a bisected true ceiling between a pass and a fail — the real drafter ceiling may be higher, up to `qwen38_unsloth_c` (188416). Flagged for the owner; not investigated further inside this budget.

### sweep-qwen38-unsloth (arms)

nmax0 (no drafter, `-c 188416`, `--cache-ram 0`): depths 4096, 138240, 147478.

| depth | tok/s | peak tok/s |
|--:|--:|--:|
| 4096 | 13.60 | 14.00 |
| 138240 | 8.19 | 9.00 |
| 147478 | 7.97 | 8.00 |

Files: `results/server-sweep-nmax0.log`, `results/benchy-sweep-nmax0.md`, `results/benchy-sweep-nmax0.log`.

nmax1 (`--spec-type draft-mtp --spec-draft-n-max 1`, `-c 139264`, `--cache-ram 0`): depths 4096, 138240.

| depth | tok/s | peak tok/s |
|--:|--:|--:|
| 4096 | 12.23 | 13.00 |
| 138240 | 7.34 | 8.00 |

nmax1 reads slower than nmax0 at both shared depths (12.23<13.60 at 4k, 7.34<8.19 at 138k). Per the sweep rule, the climb stops here: nmax2 and nmax3 are not run.
Files: `results/server-sweep-nmax1.log`, `results/benchy-sweep-nmax1.md`, `results/benchy-sweep-nmax1.log`.

sweep-qwen38-unsloth closed. Arm table: nmax0 (13.60/8.19/7.97 @ 4k/138k/147k) is the fastest arm at every shared depth; the drafter cost more than it paid on this file, matching run 16's finding for other dense Qwen3.8 builds on this Mac.

Coordinator answer (2026-09-14, on the push through 80f5f1c):
1. The drafter `-c` search estimate was a planning error (it diffed wired at `-c 4096` against wired at `-c 188416`), so 139264 is not a ceiling. Keep `qwen38_unsloth_mtp_c` = 139264 for the arm table only; the arms compare at 138240, which stays valid. In `qwen38-unsloth-serving`, if the agent arm is a drafter arm: bisect that arm's `-c` between 139264 (pass) and 188416 in multiples of 8192, at most three loads, each with one real 4096-token completion. Write the largest pass as `qwen38_unsloth_agent_c`, re-read that arm's benchy cell at `qwen38_unsloth_agent_c` minus 1024, and take the window from it by the usual rule. If `nmax0` is the agent arm, none of this applies.
2. Branch collision: origin already has `qwen3.8-27b-iq3s-xhigh-guided-v3-issue-13` from the Linux run. Use alias `qwen3.8-27b-iq3s-m1` everywhere for the smoke and both Mendel rows: the llama-server `--alias`, a pi entry with that id (copy of `qwen3.8-27b-iq3s`, same thinking map), `benchmarks/mendel-smoke.sh qwen3.8-27b-iq3s-m1 xhigh`, `./run-worker.sh qwen3.8-27b-iq3s-m1 pi blind xhigh` / `guided xhigh`. The row's `model` value stays `qwen3.8-27b-iq3s (unsloth UD-IQ3_S, xhigh, m1-max-32gb)`; name the alias in the config note.
3. Wired above 25000 at the two top ladder rungs is not a stop: real requests passed and swap stayed flat. Noted, no action.

Owner instruction (2026-09-14, direct to the runner): withdrawn. The owner first said `qwen38-unsloth-mendel-blind-xhigh` was a mistake in the order, then corrected: the original order was right, keep the blind block in queue as AGENT.md has it. No skip.

### qwen38-unsloth-serving

Not a measurement; applies the serving rule from the sweep table.

1. **Agent arm.** At depth `qwen38_unsloth_mtp_c` minus 1024 (138240): nmax0 reads 8.19 tok/s, nmax1 reads 7.34 tok/s. Candidate = nmax0. Window (nmax0 rule): `qwen38_unsloth_clean` (147478) rounded down to a multiple of 4096, at or under `qwen38_unsloth_c` (188416) = 147456.
2. **Compaction check.** ISTA's blind peak was 117940. The candidate's window (147456) is not under 122880, so the check does not fire; agent arm stays nmax0. Not a drafter arm, so the coordinator's added bisection step for `qwen38-unsloth-serving` does not apply.
3. **EvalPlus arm.** Highest tok/s at depth 4096: nmax0 (13.60) beats nmax1 (12.23). Eval arm = nmax0.

`qwen38_unsloth_agent_arm` = nmax0 (no drafter)
`qwen38_unsloth_agent_c` = 188416
`qwen38_unsloth_window` = 147456
`qwen38_unsloth_keep` = pi's default (window ≥ 65536, so no override)
`qwen38_unsloth_eval_arm` = nmax0

### qwen38-unsloth-smoke-xhigh

Agent arm (nmax0, `-c 188416`, alias `qwen3.8-27b-iq3s-m1`) loaded clean. `gh auth status` passes. pi entry `qwen3.8-27b-iq3s-m1` added (copy of `qwen3.8-27b-iq3s`, same thinking map, `contextWindow` 147456 pinned to `qwen38_unsloth_window`).

Deviation: `git -C ~/code/mendel-benchmark stash clear` is blocked by this session's sandbox (destructive-action guard), every attempt. `git stash list` read empty before the attempt, so nothing was at risk; not a stop condition, flagged for the owner. The runner cannot self-authorize past this guard.

Smoke result: `SMOKE-MENDEL model=qwen3.8-27b-iq3s-m1 level=xhigh task=xtend window=147456 calls=13 distinct=13 longest_run=1 loop=ok:1.00 compactions=0 splits=0 peak=6933 commits=1 clean=yes end=stop wall_s=206 verdict=pass`. Session log checked: 11/11 assistant turns carry a thinking block, so xhigh reached the server. `qwen38_unsloth_smoke` = pass.

## Handing over

Not started.
