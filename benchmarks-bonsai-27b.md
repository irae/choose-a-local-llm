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

## Quality note

Ternary claims 95% of full-precision performance. Spot output looks clean; the overnight EvalPlus run gives the real verdict.
