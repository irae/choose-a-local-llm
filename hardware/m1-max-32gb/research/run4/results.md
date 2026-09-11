# Research run 4 — results

One section per item. Every number with the exact command that
produced it and the file under `results/` that holds the evidence.

A benchy table has one row per depth: depth, benchy tok/s, its
standard deviation across the repeats, the creep's tok/s at the same
depth, the difference in percent, and the draft acceptance read from
the server log. A cell without acceptance is not a drafter measurement.

## `benchy-ab`

`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp` rev `d562806`,
`--no-mmproj`, f16 KV, `--parallel 1`, wired 25000. `llama-benchy`
0.4.0, tokenizer `Qwen/Qwen3.8-27B`, default corpus (Sherlock Holmes,
144480 tokens). No `--extra-body`, no sampling parameter: the server
default applied to every request.

Benchy invocation, minus the depths:

```bash
llama-benchy --base-url http://127.0.0.1:8081/v1 --model qwen3.8-27b \
  --tokenizer Qwen/Qwen3.8-27B \
  --pp 512 --tg 256 --depth <depths> \
  --runs 2 \
  --post-run-cmd 'sleep 60; vm_stat | head -12 >> <vm log>' \
  --format md --save-result <result md>
```

`--warmup-runs 1` from the item is not a flag in 0.4.0. Warmup is on
by default (one warmup request per test, then the two runs), so the
effect is the item's. The exact runner is `results/run-benchy.sh`.

Benchy's `depth` is the conversation before the 512-token prompt, so
the server sees depth plus about 510 tokens. The creep's depth column
is the whole prompt. The pairs below are the nearest creep row.

### Arm `none`: no drafter, `-c 163840`, depths 4096, 49152, 98304

Server: the published command shape with no `--spec-type` and no
`--spec-draft-n-max`. Creep pair: bench13 `creep-ista-nodrafter.tsv`
(2026-09-09). Benchy ran 20:03 to 21:34.

| depth | server prompt | benchy tok/s | sd | creep tok/s (depth) | diff | acceptance |
|--:|--:|--:|--:|--:|--:|--:|
| 4096 | 4609 | 13.94 | 0.00 | 14.14 (4114) | -1.4% | no drafter |
| 49152 | 49664 | 11.36 | 0.05 | 11.51 (49198) | -1.3% | no drafter |
| 98304 | 98816 | 9.47 | 0.00 | 9.69 (98338) | -2.3% | no drafter |

Every cell within 5 percent: the `none` arm passes. Server-side
decode per request (`eval time`, 256 tokens; first of each three is
the warmup): 13.97, 13.94, 13.93 at 4k; 11.38, 11.31, 11.41 at 49k;
9.45, 9.47, 9.47 at 98k. Prefill 129 / 108 / 91 tok/s; every request
prefilled its full depth, benchy varies the prompt so the server's
prompt cache never hit.

Memory: wired 24.0 to 24.5 GB across the arm (`benchy-none-vm.log`,
84 `vm_stat` samples, 7 tests). Swap used read 258 MB at preflight
and 3776 MB after the arm; the server log shows it saving a prompt
cache entry per request (3.7 GB each at 98k) and evicting older ones.
Decode did not move between runs, so the swap did not time the
cells. The arm did not sample swap; the `n3` arm does.

Files: `results/benchy-none.md`, `results/benchy-none.stdout.log`,
`results/benchy-none-vm.log`, `results/server-benchy-none.log`.
