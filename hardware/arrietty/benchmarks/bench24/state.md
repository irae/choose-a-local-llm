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
| `bonsai2_pq2_window` | pending | `bonsai2-pq2-smoke-xhigh` |
| `bonsai2_pq2_think_budget` | 25209 | `bonsai2-pq2-calibrate-think` |
| `bonsai2_pq2_answer_budget` | 2048 | `bonsai2-pq2-calibrate-think` |
| `bonsai2_pq2_max_tokens` | 27257 | `bonsai2-pq2-calibrate-think` |
| `bonsai2_27b_ptq1_c` | 245760 | `bonsai2-ptq1-kvpick` |
| `bonsai2_27b_ptq1_kv` | q8_0 | `bonsai2-ptq1-kvpick` |
| `bonsai2_ptq1_clean` | 244736 | `sweep-bonsai2-ptq1` |
| `vram_start_mb` | pending | `nvidia-smi`, session start |
| `evalplus_python` | pending | pipx venv |

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

`machine-setup`, "The server" gate, `bonsai2-pq2-kvpick`, `sweep-bonsai2-pq2`, `bonsai2-pq2-calibrate-think`, `bonsai2-pq2-budget-xhigh` (gate passed: base 0.982 ≥ 0.800), `bonsai2-pq2-forced-rerun`, `bonsai2-ptq1-kvpick`, `sweep-bonsai2-ptq1`, `bonsai2-pq2-smoke-xhigh` (pass, 37s, 1 commit), and `bonsai2-pq2-mendel-blind-xhigh` (complete, 245 tool calls, peak ctx 192679/208896, loop ok, wall 1:32:27) are done. Score/worst defect await the coordinator's judgement pass. Next: `retry-sweep` (empty — no block waited on a human).
