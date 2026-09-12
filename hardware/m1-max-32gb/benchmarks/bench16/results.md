# Run 16 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence. A benchy table carries depth, benchy tok/s and its standard
deviation, the site's tok/s at the nearest depth, the difference in
percent, acceptance, swap, and the tokenizer. A simulator(mendel) row
states its score, libraries done, worst defect, wall clock, peak
context, compaction count, and the sampling read from `meta.json`.
A table carries no pick.

## `benchy-qwen38-atomicchat-drafter`

`AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S`, rev `ca10ebc`, `--no-mmproj`,
f16 KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`,
`--parallel 1`, `-c 106496`, wired 25000. `llama-benchy` 0.4.0,
tokenizer `Qwen/Qwen3.8-27B`, code corpus (`corpus-mendel-js.txt`),
pp 512, tg 256, 2 runs after warmup.

| depth | benchy tok/s | sd | site tok/s | diff | acceptance (warmup) | acceptance (runs) | swap MB |
|--:|--:|--:|--:|--:|--:|--:|--:|
| 4096 | 8.10 | 0.05 | 15.8 | -48.7% | 42.0% | 35.6%, 34.9% | 447.62, no growth |
| 98304 | 7.43 | 0.34 | 10.3 | -27.9% | 60.1% | 69.4%, 60.3% | 447.62, no growth |

Files: `results/benchy-qwen38-atomicchat-drafter.md`,
`results/server-benchy-qwen38-atomicchat-drafter.log`,
`results/benchy-qwen38-atomicchat-drafter-vm.log`.
Wired stayed near 24900-25000 MB across the block. No swap growth.
