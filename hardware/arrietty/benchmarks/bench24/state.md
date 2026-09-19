# Run 24 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `llama_server_prism` | `~/.local/share/choose-a-local-llm/llama.cpp-prism/release/bin/llama-prism-b10685-7dffb15/llama-server` | the fork, "The server" |
| `prism_fork_commit` | `7dffb158d` (release tag `prism-b10685-7dffb15`, build 10685) | the fork, "The server" |
| `budget_flags_present` | yes, both `--reasoning-budget` and `--reasoning-budget-message` | "The server", step 5 |
| `bonsai2_27b_pq2_c_q8` | 212992 | `bonsai2-pq2-kvpick` |
| `bonsai2_27b_pq2_c_f16` | 122880 | `bonsai2-pq2-kvpick` |
| `bonsai2_27b_pq2_c` | 212992 | `bonsai2-pq2-kvpick` |
| `bonsai2_27b_pq2_kv` | q8_0 | `bonsai2-pq2-kvpick` |
| `sampling_temperature` | 1.0 | server `/props`, `bonsai2-pq2-kvpick` |
| `sampling_top_p` | 0.95 | server `/props`, `bonsai2-pq2-kvpick` |
| `sampling_top_k` | 20 | server `/props`, `bonsai2-pq2-kvpick` |
| `sampling_min_p` | 0.05 | server `/props`, `bonsai2-pq2-kvpick` (runbook expected 0.0 from GGUF metadata) |
| `bonsai2_pq2_clean` | 211968 | `sweep-bonsai2-pq2` |
| `eval_tools_hash` | `204acec` | `local-llm-eval-tools`, `sweep-bonsai2-pq2` |
| `bonsai2_pq2_window` | 208896 | `bonsai2-pq2-smoke-xhigh` |
| `bonsai2_pq2_think_budget` | 25209 | `bonsai2-pq2-calibrate-think` |
| `bonsai2_pq2_answer_budget` | 2048 | `bonsai2-pq2-calibrate-think` |
| `bonsai2_pq2_max_tokens` | 27257 | `bonsai2-pq2-calibrate-think` |
| `bonsai2_27b_ptq1_c` | 245760 | `bonsai2-ptq1-kvpick` |
| `bonsai2_27b_ptq1_kv` | q8_0 | `bonsai2-ptq1-kvpick` |
| `bonsai2_ptq1_clean` | 244736 | `sweep-bonsai2-ptq1` |
| `vram_start_mb` | 626 MiB of 16311 MiB | `nvidia-smi`, session start |
| `evalplus_python` | `/home/irae/.local/share/pipx/venvs/evalplus/bin/python` | pipx venv, EvalPlus 0.3.1 |
| `bonsai2_pq2_f16_c` | 122880 | `bonsai2-pq2-f16-kvpick` |
| `bonsai2_pq2_f16_clean` | 121856 | `sweep-bonsai2-pq2-f16` |
| `bonsai2_pq2_f16_window` | 118784 | `bonsai2-pq2-mendel-blind-xhigh-f16` |
| `bonsai2_pq2_f16_blind` | 72/100, worst defect MEDIUM, end_reason complete | `bonsai2-pq2-mendel-blind-xhigh-f16` |
| `bonsai2_ptq1_f16_c` | 139264 | `bonsai2-ptq1-f16-kvpick` |
| `bonsai2_ptq1_f16_clean` | 138240 | `sweep-bonsai2-ptq1-f16` |
| `bonsai2_ptq1_window` | 241664 | `bonsai2-ptq1-mendel-blind-xhigh` |
| `bonsai2_ptq1_blind` | 57.5/100, worst defect CRITICAL, end_reason complete | `bonsai2-ptq1-mendel-blind-xhigh` |
| `bonsai2_ptq1_f16_window` | 135168 | `bonsai2-ptq1-f16-mendel-blind-xhigh` |
| `bonsai2_ptq1_f16_blind` | 82/100, worst defect CRITICAL (trap A), end_reason complete | `bonsai2-ptq1-f16-mendel-blind-xhigh` |
| `bonsai2_ptq1_f16_think_budget` | 30000 (capped) | `bonsai2-ptq1-f16-evalplus-calibrate` |
| `bonsai2_ptq1_f16_answer_budget` | 2048 | `bonsai2-ptq1-f16-evalplus-calibrate` |
| `bonsai2_ptq1_f16_max_tokens` | 32048 | `bonsai2-ptq1-f16-evalplus-calibrate` |
| `bonsai2_ptq1_f16_evalplus` | base 0.970, plus 0.939, 0 empty, 6 forced, gate passed | `bonsai2-ptq1-f16-evalplus-budget-xhigh` |
| `bonsai2_ptq1_f16_forced_rerun` | 4 forced-pass, 2 forced-fail-loop, budget unchanged | `bonsai2-ptq1-f16-evalplus-forced-rerun` |
| `bonsai2_pq2_f16_think_budget` | 30000 (capped) | `bonsai2-pq2-f16-evalplus-calibrate` |
| `bonsai2_pq2_f16_answer_budget` | 2048 | `bonsai2-pq2-f16-evalplus-calibrate` |
| `bonsai2_pq2_f16_max_tokens` | 32048 | `bonsai2-pq2-f16-evalplus-calibrate` |
| `bonsai2_pq2_f16_evalplus` | base 0.982, plus 0.945, 0 empty, 6 forced, two parts around an owner stop | `bonsai2-pq2-f16-evalplus-budget-xhigh` |
| `bonsai2_pq2_f16_forced_rerun` | 3 forced-pass, 3 forced-fail-loop, budget unchanged | `bonsai2-pq2-f16-evalplus-forced-rerun` |

## EvalPlus group order

The four blind scores, sorted best first: `ptq1-f16` 82, `pq2-f16` 72, `ptq1` (q8_0) 57.5. This is a sort of three numbers, not a pick, so it stayed with the runner (owner via coordinator, 2026-09-18).

Group order: **`ptq1-f16`, then `pq2-f16`, then `ptq1`.** Order inside each group is fixed: calibrate, budget-xhigh, forced-rerun.

`pq2-f16-evalplus-calibrate` was started first (started while `ptq1-f16`'s blind score was still computing, to keep the card busy) and stopped after 1 row once the 82 score landed and beat 72 — `calibrate.py` resumes the file that exists, so that row is not lost; the group resumes it when its turn comes.

## Pause and stray client (2026-09-18 to 2026-09-19)

The owner stopped run 24 at about 22:33 -03 (01:33 UTC), inside `bonsai2-pq2-f16-evalplus-budget-xhigh`, at 64/164 problems. The wrapper `run-humaneval.sh` (pid 222241) died, but its EvalPlus client (pid 222249) lived on and sent requests to run 27's server on port 8081 until the owner killed it.

Check before the resume: every output file of the block (`finish.jsonl`, `codegen.log`, both sample files) has its last write at 22:29:01 -03, before the stop. Samples written after the stop: **0**. All 64 samples come from the run 24 server. Nothing was deleted. The block resumes from problem 64.

Planning estimate, not a result: about 34 MiB of KV per 1024 tokens at
q8_0, from the `qwen35` architecture. With weights of about 6.7 GiB,
the card may hold the whole trained window of 262144 tokens. The
ladder decides.

## `machine-setup`

`evalplus_python`: `/home/irae/.local/share/pipx/venvs/evalplus/bin/python` (EvalPlus 0.3.1, already installed). `vram_start_mb`: 626 MiB of 16311 MiB. `MemAvailable`: 20232 MB. `df -h ~`: 32G free after both downloads (was 42G).

Both files fetched with `hf download`, default cache. Sizes match the runbook table exactly:

| file | size (bytes) | sha256 |
|---|--:|---|
| `Ternary-Bonsai-2-27B-PQ2_0.gguf` | 7206168928 | `3907dc1658db1f78a9826bf8d5bcb8dc65db0d466388937af57f2294fae62ec1` |
| `Ternary-Bonsai-2-27B-PTQ1_0.gguf` | 5946648928 | `53107f530aa52eb00912263ab1ee29bd199261c87cd7b4ad4ca1318c1fe33ee3` |

Corpus server (port 8089) not yet started; will start before the sweep blocks need it.

### The server (the run's first gate)

**Deviation: the release tag used is not literally `/releases/latest`.** At `2026-09-17T22:2x`, `releases/latest` resolved to `prism-b10687-5d80cff`, whose release body text links Linux/macOS binaries, but the actual uploaded assets for that tag are three Windows CUDA runtime zips only (checked with `gh api .../releases/tags/prism-b10687-5d80cff --jq '.assets[].name'`) — the Linux/CUDA builds were still building in CI. The previous release, `prism-b10685-7dffb15` (build 10685, commit `7dffb158d`), has the full asset set, including `llama-prism-b10685-7dffb15-bin-linux-cuda-12.8-x64.tar.gz`. Used that one. This is the newest release that actually carries a Linux CUDA binary, so it satisfies "newest release binary with CUDA support" in spirit.

No source build was attempted: this machine has neither `cmake` nor a CUDA toolkit (`nvcc`) installed, and installing either needs `sudo pacman -S`. The prebuilt CUDA 12.8 release binary was tried first per usual practice, and it detects the card correctly (`CUDA0: NVIDIA GeForce RTX 5060 Ti (15885 MiB, 15126 MiB free)`) — no source build was needed. The CUDA runtime shared libs (`libcudart.so.12`, `libcublas.so.12`, `libcublasLt.so.12`) are not bundled in the release tarball; reused the ones already on this machine from run 17's stock build, `~/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/lib/`, via `LD_LIBRARY_PATH`.

Binary: `~/.local/share/choose-a-local-llm/llama.cpp-prism/release/bin/llama-prism-b10685-7dffb15/llama-server`, `version: 0.2.0-dev (build 10685, commit 7dffb158d)`. Archive sha256 `4ec1572702fa3fd359653528fa5625fdd9c7ae02dedab7146da7773dae48cf2c` (checked against the GitHub release asset digest, matched).

`--help | grep -A1 reasoning-budget`: both `--reasoning-budget N` and `--reasoning-budget-message MESSAGE` are present. The run proceeds as written, with the thinking-budget blocks.

**The probe.** Served the primary file (`PQ2_0`) at `-c 4096`, `--no-mmproj --parallel 1 -ngl 999 --fit off -fa on`, port 8081. No `unknown type` line, no error, in `results/server-probe.log`. Sent one real chat completion with thinking on at xhigh (`chat_template_kwargs.reasoning_effort=xhigh`):

Prompt: "Write a Python function that returns the nth Fibonacci number using memoization. Keep it short."

`reasoning_content` (128 completion tokens total): "We need respond to user: ... Keep short. Provide function." — coherent, on-topic reasoning trace.

`content`: a correct, well-formed Python memoized Fibonacci function using a mutable default-arg dict. Not garbage, not empty, not a refusal.

`nvidia-smi` after load: 7919 MiB of 16311 MiB used. Server stopped after the probe; vram back to 626 MiB.

Files: `results/server-probe.log`, `results/probe-response.json`.

GGUF sampling defaults (`general.sampling.*`) were not printed at this server's default log verbosity; will read them from a `-c 32768` block load log (calibration or budget-xhigh) and record then, per the runbook's "Essentials" instruction.

## Handing-over

**The run ended: every block on the list ran, in order.**

- `machine-setup`: both files fetched and hash-checked; the fork's newest release lacked a Linux CUDA asset (CI still building), so the prior release `prism-b10685-7dffb15` was used instead — it detects the card and proves out.
- "The server" gate: passed on the first try with the prebuilt binary; no source build was needed (this machine has no cmake or CUDA toolkit, so a source build would have needed `sudo` — never triggered because the prebuilt worked).
- `bonsai2-pq2-kvpick`: q8_0 picked, `-c` 212992.
- `sweep-bonsai2-pq2`: clean to the deepest tested depth (211968, 14.5 tok/s).
- `bonsai2-pq2-calibrate-think`: 7/10 converged; think_budget 25209, answer_budget 2048, max_tokens 27257.
- `bonsai2-pq2-budget-xhigh`: base 0.982, plus 0.939, 0 empty, 7 forced. Agent gate passed (0.800 floor), so the smoke and blind row ran.
- `bonsai2-pq2-forced-rerun`: 4 forced-failed, all four forced-fail-loop (genuine non-convergence). Corrected budget unchanged.
- `bonsai2-ptq1-kvpick`: q8_0 picked, `-c` 245760 (near the full 262144 trained window — the smaller weights leave much more KV room than PQ2). f16 hit a live CUDA OOM abort at 147456, not just a clean reject.
- `sweep-bonsai2-ptq1`: clean to the deepest tested depth (244736, 12.8 tok/s).
- `bonsai2-pq2-smoke-xhigh`: pass, 37s, 1 commit, no loop. Registered `bonsai2-27b-pq2` in `~/.pi/agent/models.json` for this (backup at `~/.pi/agent/models.json.bak-run24`).
- `bonsai2-pq2-mendel-blind-xhigh`: end_reason complete, 245 tool calls, peak ctx 192679/208896 (92.2%), loop flag ok, 0 compactions, wall 1:32:27. Scored by a judgment subagent (best available model) from the evidence pack, the session log, and the worktree diff: **60/100, worst defect CRITICAL** (an exit-hook `fs.rmSync` deletes the debug manifest the user needs to inspect, before they can read it — commit `ede1f89c`). Full per-criterion breakdown in `results.md`.
- `retry-sweep`: empty. No block waited on a human this run; every recoverable failure (a few CUDA OOMs during the kvpick ladders) was retried inside its own block per the owner rule.

**Deviations from the runbook, all told to the coordinator at the block they happened:**
1. The fork's release used is `prism-b10685-7dffb15`, not literally the tag `releases/latest` resolved to at run start — that newest tag's Linux/macOS assets were not yet uploaded when the run began.
2. No source build attempted or needed: the prebuilt CUDA 12.8 binary loads and serves correctly on this sm120 card via PTX JIT, so the "no release matches this card" branch of the runbook did not apply as written.
3. The GGUF metadata's `min_p 0.0` line in the runbook's Essentials does not match what the server actually applies (`min_p 0.05`, read from `/props`); every config note in this run carries the measured value.
4. `bonsai2-pq2-forced-rerun`'s summary note originally said "every forced problem still passed" — corrected after the forced-rerun block found 4 of 7 forced problems actually failed their tests.

**Machine state left behind**: no `llama-server` process running, port 8081 free, VRAM at 626 MiB (baseline). Corpus server (port 8089) stopped after `sweep-bonsai2-ptq1`. `~/.pi/agent/models.json` carries one new entry, `bonsai2-27b-pq2`, with a backup alongside it. The Mendel worktree `~/code/mendel-bench-bonsai2-27b-pq2-xhigh` and its branch `bonsai2-27b-pq2-xhigh-issue-13` are left in place, unscored, per house rules — do not delete until scored. No `Mendel Daemon` process was left running.

**Evidence archived**: `tools/archive-evidence.sh hardware/arrietty/benchmarks/bench24/results run24` run at session close, and again after the score landed. `pkill -f "Mendel Daemon"` checked; none was running.

**Owner word, 2026-09-18, first close**: the coordinator asked me to score the blind row myself (a subagent on the best available model, never a smaller one), then stop and hold the card for run 23's resume. Done at commit `9256151`. No block after `bonsai2-pq2-mendel-blind-xhigh` ran; the GPU was not touched again after this row closed.

**Owner word, 2026-09-18, reopen**: the owner added the f16 arm — three more blocks after the run first closed (`bonsai2-pq2-f16-kvpick`, `sweep-bonsai2-pq2-f16`, `bonsai2-pq2-mendel-blind-xhigh-f16`). Master gained the commits locally (not yet on origin) before the reopen; `git merge master` brought them into `run24`. All three new blocks ran on the same fork binary at the same level, **no EvalPlus, no calibration and no smoke in this arm** — the q8_0 arm of the same file already passed both gates.

- `bonsai2-pq2-f16-kvpick`: `-c` 122880 confirmed (the fail at 131072 was already known from the q8_0-arm's earlier ladder; the gap was already the ladder's finest step, so one load closed it).
- `sweep-bonsai2-pq2-f16`: clean to 121856, deepest tested (25.1 tok/s).
- `bonsai2-pq2-mendel-blind-xhigh-f16`: end_reason complete, 230 tool calls, peak ctx 110354/118784, loop ok, 1 compaction, wall 1:14:44. Scored by a judgment subagent: **72/100, worst defect MEDIUM** (the chalk port keeps forced `enableColor`, against the blind prompt's Node-defaults requirement). The CRITICAL exit-hook regression from the sibling q8_0 row does not repeat here. **Correction caught and fixed**: the scoring subagent's own headline claimed 78/100, but its ten-criterion breakdown summed to 72; the verified sum, 72, is what's recorded — the subagent's unsupported round-up was not used.

No `Mendel Daemon` process was left running. Registered `bonsai2-27b-pq2-f16` in `~/.pi/agent/models.json`, alongside the earlier `bonsai2-27b-pq2` entry (same backup file). GPU idle at 622-626 MiB baseline after every block of this arm; no server left running.
