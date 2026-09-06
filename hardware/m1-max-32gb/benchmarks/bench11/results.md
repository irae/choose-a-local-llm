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

**Not accepted as the block's clean-machine finding**: this creep ran
right after 8 load/kill cycles from the binary search above, not on a
machine clean since reboot as block 1 requires. See `state.md` for the
deviation. Needs a redo after an actual clean start (reboot, preflight
all `ok`) before this can close the row.
