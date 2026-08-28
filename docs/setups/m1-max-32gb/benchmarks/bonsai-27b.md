# Ternary Bonsai-27B on M1 Max 32 GB — mlx-lm (+ llama-server pending)

Ternary Bonsai 27B (PrismML): Qwen3.6-27B compressed to ternary (2-bit) weights. Claims 95% of full-precision performance. No MTP head (removed from the checkpoint). Trained context 262144 (confirmed in GGUF metadata).
Temperature 0, `n_predict` 256 unless noted. Warmup request before each measurement.

Prompts: same as the other models (py = ISO dates, js = deep clone).

## Variants

| variant | format | backend | size | status |
|---|---|---|---|---|
| Ternary-Bonsai-27B mlx-2bit | MLX | mlx-lm | 7.2 GB | tested |
| Ternary-Bonsai-27B Q2_0 | GGUF | llama-server | 6.7 GB | downloaded, BLOCKED — needs a llama.cpp newer than build 10621 (Q2_0 tensor layout mismatch); retest after the next brew release |

The repo also ships `PQ2_0` and `Q2_g64` files. The `-hf ...:Q2_0` tag wrongly matches PQ2_0 — pin the file with `--hf-file Ternary-Bonsai-27B-Q2_0.gguf`.

## Decode speed — mlx-lm

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit --port 8081
```

| prompt | decode tok/s | peak memory |
|---|---|---|
| py | 28.59 | 7.9 GB |
| js | 28.59 | 7.9 GB |

## Context — MLX

No slot preallocation on mlx-lm; KV grows per request toward the 262K trained window, memory permitting. Staged probe (`mlx_lm` API, 32-token generations, warmup first):

| prompt depth | pp tok/s | peak memory |
|---|---|---|
| 16K | 144 | 13.0 GB |
| 32K | 137 | 15.5 GB |
| 64K | 117 | 20.8 GB |
| 96K | 96 | 26.4 GB |

**Max context ≈ 96K** — same reach as Qwen3.8 GGUF on llama-server, at 28.6 vs 16.9 tok/s decode. 128K is out of reach (~31 GB projected). Qwen-on-MLX OOMs at 64K.

## Multi-session — two server instances

`mlx_lm.server` has no slots (one request at a time), so concurrency = two OS processes, each with its own weight copy (ports 8081/8082). Measured (256 tokens, temp 0, warmup first, wall-clock through the HTTP server):

| scenario | tok/s |
|---|---|
| solo (one instance active) | 24.6 |
| concurrent (both decoding) | 14.0 / 13.9 each |

Both servers: 14.9 GB RSS combined. ~12 GB left for KV → roughly 2×35K context by the measured slope (not verified at depth). Bandwidth splits almost perfectly under concurrency.

**Decision: ruled out.** Two servers mean two weight copies and per-agent endpoint wiring in the harness — not worth it. Parallel serving is llama-server's job; Bonsai gets a multi-session story when its ternary GGUF loads on a stable brew llama.cpp.

## Quality — EvalPlus HumanEval+ (night 2, fair budget)

**pass@1 0.915 base / 0.884 plus** (mlx, thinking on, output budget 10240,
temperature 0). Night 1's flawed 3072 cap had scored it 0.640/0.634 — the
biggest correction of any model. 5/164 completions stay empty even at the full
budget: a real model ceiling, not a harness artifact. The ternary 95% claim
holds up in practice. Bonsai is also the least disruptive model to run while
working (moderate fan noise, ~8 GB weights) — a practical all-day
background-agent candidate. Details: `night2/results.md`.

## Corrected serving command + depth sweep (limit 25000, 2026-08-28)

Always start the mlx server with a bounded prompt cache — the default pools
several distinct KV caches (multi-GB each at depth) and behaves like a memory
leak across differently-shaped requests; it produced a false 44K OOM:

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081
```

Decode vs used context (append-only prompts, streamed timing, 64-tok probes):

| depth | decode tok/s |
|---|---|
| 4K | 24.5 |
| 8K | 24.2 |
| 16K | 22.9 |
| 24K | 22.0 |
| 32K | 20.5 |
| 49K | 18.8 |
| 53K | 18.6 |
| **57K** | **18.2 — deepest healthy point** |
| ~61K | Metal OOM — **ceiling 57-61K** |

Flattest depth curve measured (-23% over 45K); the limit is memory, not
speed. The old 96K/26.4 GB figures were taken at the retired 27000 limit and
are withdrawn from the HTML. PrismML's bigger-context figures (100K @ ~15 GB,
262K with 4-bit KV) require their llama.cpp fork path — see night 3's
bonsai-prism block.

## PrismML llama.cpp fork (prism-b10660), Q2_g64 — measured 2026-08-28

Binary: `~/prism-llama/llama-server` (side-by-side install, `prism-llama`
alias; rolling channel, user-approved fork exception). Weights:
`Ternary-Bonsai-27B-Q2_g64.gguf` (group-64; the plain `Q2_0` file is the
legacy layout and does not load — keep for debugging). Drafter: converted
locally with the fork's `gguf-dspark-to-dflash` from the bf16 file
(the published `dspark-Q4_1` is legacy too); output
`~/prism-llama/models/Ternary-Bonsai-27B-dspark-dflash-Q4_0.gguf` (602 MB,
shared tensors dropped). DSpark is output-lossless at temperature 0.

Baseline (32K alloc, q8 KV): 16.6/16.6 tok/s py/js, RSS 9.5 GB.
DSpark sweep (n-max 2/3/4): n2 best — py 19.1 (69% accept), js 21.5 (84%).

Depth sweeps, 8 tok/s early stop (fair frame: same 128K alloc):

| config | 4K | 16K | 24.5K | 33K | floor | RSS |
|---|---|---|---|---|---|---|
| q4 plain, 64K alloc | 14.6 | 10.6 | 9.0 | 7.8 | **~30K** | **9.8 GB** |
| q4 plain, 128K alloc | 14.6 | 10.7 | 9.0 | 7.8 | ~30K | 11.0 GB |
| q4 + dspark n2, 128K | 16.0 | 11.8 | 6.2 | – | ~20K | 16.2 GB |
| q4 + dspark n1, 64K | 16.4 | 11.3 | 7.3 | – | ~23K | 14.1 GB |
| q8 plain, 128K | 13.8 | 9.2 | 7.4 | – | ~21K | 12.8 GB |
| q8 + dspark n2, 128K | 16.5 | 10.0 | 4.9 | – | ~20K | 18.2 GB |
| q8 plain, 262K alloc | 12.8 | 9.1 | 7.4 | – | ~21K | 17.1 GB (window fits) |

Findings: the 8 tok/s floor is depth physics (~30K best); allocation size
only taxes decode at 262K; the drafter boosts shallow decode but drops the
floor at every draft depth tried (n1 is the least bad: floor ~23K vs plain
q4's ~30K) and costs 4-5 GB; q4 KV beats q8 on both
floor and memory. Full 262K allocates in 17.1 GB — storage, not speed.
mem-watch (20 s interval) showed zero swap during all sweeps: compute-bound.

**Two serving profiles** (quality of q4+bias pending night 3 EvalPlus):
- Speed (MLX): 24.5→18.8 tok/s to the ~49K memory ceiling; RSS grows with
  depth. `mlx_lm.server ... --prompt-cache-size 2`.
- Desktop (fork): `prism-llama -m Ternary-Bonsai-27B-Q2_g64.gguf -c 65536
  --cache-type-k q4_0 --cache-type-v q4_0 -fa on -ngl 999` — 9.8 GB flat,
  floor ~30K, Mac stays usable; add the dflash drafter only for
  shallow-context serving.

## Fork multi-slot (2026-08-28)

`--parallel 2 -c 98304` (2×48K, q4 KV, no drafter): both slots decoding
concurrently at **9.8 / 9.9 tok/s** (aggregate 19.7, +35% from batching),
RSS **10.0 GB**. Two agents above the 8 tok/s floor with ~20 GB left for the
system — the only multi-agent config measured that keeps the machine free.
3×32K is the projected next probe for grunt-agent swarms.
