# Run 27 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `adapter_sha256` | `f1669534803d340a496015f5c45125f3437b4d13ec764f40e34488ce83967f42` | coordinator, verified 2026-09-18 |
| `adapter_size` | 9682464 | coordinator, verified 2026-09-18 |
| `llama_server_prism` | `prism-b10685-7dffb15`, commit `7dffb158d` | run 24, already installed |
| `orca_c` | 139264 | `orca-ptq1-f16-ladder`, planning value 139264 |
| `orca_clean` | pending | `sweep-orca-ptq1-f16` |
| `orca_window` | pending | the agent row |
| `vram_start_mb` | 618 | `nvidia-smi`, session start |

The unablated arm of the same file and cache, from run 24, to read
against: `-c 139264`, window 135168, 42.1 / 37.3 / 30.1 / 22.4 tok/s at
4096 / 24576 / 65536 / 138240, blind agent row 82 with a CRITICAL trap
A and 17 chore-typed commits, peak context 127141 with one compaction.

## Prep, no GPU touched (2026-09-18)

Run 24 holds the card, mid-EvalPlus. No server started, no model
loaded, no scoring script run. This section answers the coordinator's
five questions, evidence first.

### 1. `$LLAMA_SERVER --help`: `--lora` and `--lora-scaled`

`$LLAMA_SERVER` resolves to
`~/.local/share/choose-a-local-llm/llama.cpp-prism/release/bin/llama-prism-b10685-7dffb15/llama-server`.
`--version`:

```
version: 0.2.0-dev (build 10685, commit 7dffb158d)
built with GNU 11.4.0 for Linux x86_64
```

Matches the runbook's `prism-b10685-7dffb15` / `7dffb158d`. `--help`
prints both flags:

```
--lora FNAME                            path to LoRA adapter (use comma-separated values to load multiple
--lora-scaled FNAME:SCALE,...           path to LoRA adapter with user defined scaling (format:
--lora-init-without-apply               load LoRA adapters without applying them (apply later via POST
                                        /lora-adapters) (default: disabled)
```

### 2. `scripts/selfcheck.py`: what it checks, GPU/model load

It calls `bonsai_abliterate.pack.load_pack`, which loads the **MLX**
pack (`--pack /path/to/Ternary-Bonsai-2-27B-mlx-2bit`), then runs two
full forward passes (`residual_components`, before and after
`install`) to measure how much of the residual stream still lies along
the refusal direction. The docstring itself says each forward pass
costs minutes without Metal. **It needs a model load and real
inference — did not run it.** It also targets the MLX runtime path,
not the GGUF/llama.cpp `--lora` path this run uses; it cannot verify
the LoRA adapter this run serves, only the MLX pack's own wrapping.

### 3. Does the README name a build the `--lora` path needs, beyond the fork itself?

No version number or commit is named. The README says only "You need
PrismML's fork" and explains why: `PTQ1_0`/`PQ2_0` are private ggml
type ids (143, 142) outside upstream's range, so stock llama.cpp
rejects the file at header parse, and `gguf-py` itself raises
`ValueError: np.uint32(143) is not a valid GGMLQuantizationType`. No
minimum fork commit or release is named — "the fork" is the whole
requirement.

### 4. Adapter tensor count, architecture, alpha — checked without a model load

Read with the fork's own `gguf-py` (`src/gguf-py`, no `gguf` pip
package installed):

```
GGUF.tensor_count = 258
general.architecture = "qwen35" (decoded from raw bytes)
adapter.type = "lora"
adapter.lora_alpha = 1.0
```

258 tensors = 129 `lora_a`/`lora_b` pairs, matching the README's "129
`lora_a`/`lora_b` pairs... against `general.architecture = qwen35`
and `adapter.lora_alpha = 1.0`" exactly. Sample names:
`blk.0.ffn_down.weight.lora_a`, `blk.0.ffn_down.weight.lora_b`,
`blk.0.ssm_out.weight.lora_a`, ..., `token_embd.weight.lora_a`,
`token_embd.weight.lora_b`.

### 5. What the server prints on a LoRA load

From the fork's source, `src/src/llama-adapter.cpp`, function
`llama_adapter_lora_init_impl`:

```
LLAMA_LOG_INFO("%s: loading lora adapter from '%s' ...\n", __func__, path_lora);
...
LLAMA_LOG_INFO("%s: loaded %zu tensors from lora file\n", __func__, adapter.ab_map.size()*2);
```

So the server log carries two lines, both prefixed
`llama_adapter_lora_init_impl:`:

```
llama_adapter_lora_init_impl: loading lora adapter from '<path>' ...
llama_adapter_lora_init_impl: loaded 258 tensors from lora file
```

`258` is `ab_map.size()*2`, so it should read exactly 258 for this
adapter (129 pairs). A per-buffer size line also prints, from
`llama-adapter.cpp` line 389:
`LLAMA_LOG_INFO("%s: %10s LoRA buffer size = %8.2f MiB\n", ...)`,
one line per backend buffer the LoRA tensors land in. A failed load
throws `"failed to load lora adapter file from " + path`, caught in
`common.cpp` as `COM_ERR("failed to load lora adapter '%s'\n",
la.path.c_str())`.

## Reading against the runbook

Everything checked matches the runbook. One addition worth a line in
`machine-setup`, step 4 ("read the server log for the adapter... its
tensor count"): the log's tensor count is **258**, not 129 — it is
`ab_map.size()*2` (both `lora_a` and `lora_b` counted), so step 4's
probe should look for `loaded 258 tensors from lora file`, not 129.
129 is the pair count the README quotes; 258 is what the log line
itself will print.

## `machine-setup` (2026-09-18, in progress)

Card at start: 618 MiB of 16311 MiB, no llama-server. `MemAvailable` 19505 MB, `df -h ~` 13G free (95% used). `gh auth status` passes. Adapter sha256 and size match the table. The fork prints `--lora` and `--lora-scaled`.

Env for the fork: `LD_LIBRARY_PATH` must list the fork's own directory first, then run 17's CUDA lib directory. With run 17's directory first, the server loads the stock ggml and fails with `invalid ggml type 143`.

Probe at `-c 8192`: the model loaded, `GET /lora-adapters` returned the adapter at id 0, scale 1.0, and VRAM read 7059 MiB. **The server log has no `llama_adapter_lora_init_impl` line at all** (log verbosity 3, 14 lines). Runbook step 4 calls a silent load stop and ask. Counter-evidence: the endpoint lists the adapter.

**Foreign client on port 8081.** Process 222249, `run_codegen_wrapper.py` from the `choose-a-local-llm-run24` worktree, model `bonsai2-27b-pq2-f16`, up 1 h 9 min, sent requests to my probe server. Run 24 is meant to be stopped. I did not touch that process. I stopped my own server. No probe answer was checked.

Coordinator answers (2026-09-18): the log line gate is closed. `GET /lora-adapters` (id 0, scale 1.0) is the load proof, and a coherent probe answer is also required. The owner killed pid 222249; no `run_codegen_wrapper` process is left. Go given to resume.

Probe at `-c 8192` after the go: `GET /lora-adapters` returned id 0, scale 1.0; VRAM 7055 MiB of 16311 MiB after load. One chat completion at xhigh gave a correct Fibonacci function and two sentences, 1884 characters of reasoning, 562 completion tokens. Answer is coherent. `EVALPLUS_PYTHON` is `/home/irae/.local/share/pipx/venvs/evalplus/bin/python`. Corpus server runs on 127.0.0.1:8089 and stops after the sweep. `vram_start_mb`: 618. `machine-setup` done.

## `orca-ptq1-f16-ladder`

Planning value 139264 (run 24's f16 ceiling, no adapter), full command with the adapter, `--fit off`. Load: passes, VRAM 15375 MiB of 16311 MiB, no CUDA error, all layers on the GPU. Real request: 138053 prompt tokens, 16 completion tokens, served in 6 min 38 s (no cache), VRAM 15385 MiB under it. Zero `CUDA error`, `out of memory` or `cudaMalloc` lines in `results/server-orca-ladder-139264.log`.

`orca_c` = **139264**. The adapter costs no window: the ceiling equals run 24's unablated ceiling. No bisect load, because the planning value already passes and run 24 measured the next step up as a fail for this file.

## Handing-over

Prep done, no block of the run started (the card is held by run 24).
Next: `machine-setup`, when the coordinator says the card is free.
