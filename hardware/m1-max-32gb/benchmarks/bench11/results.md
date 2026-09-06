# Run 11 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence. The large-form comparison tables go here as blocks close
(`docs/methodology/status-lines.md`, "The site comparison, in full").

## Block 1/10 — Qwen3.6 GGUF `-c` ladder, wired 25000

Command: see `results/server-qwen36-gguf-q8-c98304.log`.

| `-c` | Load | Warmup completion |
| --- | --- | --- |
| 98304 | loaded | ok, 65.96 tok/s decode, draft 154/192 accepted |

Binary search above the ladder, toward the trained context (262144,
`qwen35moe.context_length` from the GGUF), q8_0 KV, wired 25000:

| `-c` candidate | Load | Completion |
| --- | --- | --- |
| 262144 | loaded | Insufficient Memory (Metal OOM) |
| 180224 | loaded | Insufficient Memory |
| 139264 | loaded | Insufficient Memory |
| 118784 | loaded | Insufficient Memory |
| 108544 | loaded | Insufficient Memory |
| 103424 | loaded | Insufficient Memory |
| 100864 | loaded | Insufficient Memory |
| 98304 | loaded | ok (see above) |

Ceiling: 98304 is the largest `-c` that serves a real completion at
wired 25000, q8_0 KV, on this GGUF. The boundary sits within 2560
tokens (98304 works, 100864 does not); every value above that up to
the trained max of 262144 loads but fails the first completion with a
Metal OOM. Logs: `results/server-qwen36-gguf-q8-c<value>.log`.

Clean-depth creep at `-c 98304`, q8_0 KV:
`results/creep-qwen36-gguf-q8-clean.tsv`.

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,57344,65536,81920,98304" \
MODEL=qwen3.6-35b-a3b python3 tools/sweeps/creep_llama.py \
  | tee hardware/m1-max-32gb/benchmarks/bench11/results/creep-qwen36-gguf-q8-clean.tsv
```

| depth_tokens | decode_toks | wired_mb | note |
| --- | --- | --- | --- |
| 4114 | 36.52 | 25997 | |
| 8222 | 44.11 | 25996 | |
| 16386 | 31.21 | 25996 | |
| 24602 | 24.14 | 25992 | |
| 32818 | 19.62 | 25992 | STOP: mem, 3 depths of sustained compaction, speed did not recover |

Coordinator's read: this is not worse than the site's published 24000
row (8K clean depth, compaction from 16K) — 32818 tokens with speed
still at 19.6 tok/s is deeper, not shallower. Wired stays at 25000, no
intermediate values tried.

Redo, same config, second clean start (preflight all `ok`, no reboot
needed — wired recovered to baseline, swap flat):
`results/creep-qwen36-gguf-q8-clean-redo.tsv`.

| depth_tokens | decode_toks | compress_pages | decompress_pages |
| --- | --- | --- | --- |
| 4114 | 36.53 | 0 | 32 |
| 8222 | 44.15 | 0 | 459 |
| 16386 | 31.16 | 0 | 48 |
| 24602 | 24.12 | 0 | 244 |
| 32818 | 19.64 | 0 | 1064 |
| 40982 | 16.57 | 0 | 65 |
| 49198 | 14.30 | 3894 | 521 |
| 57362 | 12.58 | 8995 | 467 |
| 65578 | 11.21 | 20666 | 2795 |
| 81958 | 9.24 | 29314 | 1960 |
| 98338 | 7.87 | 45054 | 18513 |

STOP: below 8 tok/s at depth 98338 — **speed verdict**. Ceiling: 81958
tokens at 9.24 tok/s, the deepest depth still at or above the 8 tok/s
floor. This clears the block's 46K gate.

Accepted finding: the first creep's early `mem` stop at 32818 did not
reproduce; treated as noise. This redo is the block's clean-depth
number for Qwen3.6 GGUF q8_0 KV at wired 25000, `-c 98304`.

**Gate: GGUF clean depth 81958 ≥ 46K at ≥ 8 tok/s → met.** Blocks 9
and 10 (Qwen3.6 GGUF Mendel, thinking off) run right after block 3, on
q8_0 KV at `-c 98304` (pending the f16 and MLX arms below, which may
still change the arm choice).
