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

## `benchy-gemma26-drafter`

`unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL`, `--no-mmproj`, f16 KV,
drafter `--spec-type draft-mtp --spec-draft-n-max 2`, `--parallel 1`,
`-c 212992`, wired 25000. `llama-benchy` 0.4.0, tokenizer
`google/gemma-4-26b-a4b-it`, code corpus (`corpus-mendel-js.txt`),
pp 512, tg 256, 2 runs after warmup.

| depth | benchy tok/s | sd | site tok/s | diff | acceptance (warmup) | acceptance (runs) | swap MB |
|--:|--:|--:|--:|--:|--:|--:|--:|
| 4096 | 60.13 | 1.81 | 60.3 | -0.3% | 74.1% | 65.2%, 74.5% | 447.62, no growth |
| 98304 | 28.19 | 0.54 | no site cell | — | 70.6% | 83.7%, 73.5% | 447.62, no growth |
| 196608 | 19.06 | 0.67 | 17.3 (at 197K) | +10.2% | 67.0% | 96.0%, 86.1% | 447.62, no growth |

Run 15, same files, no drafter, projector loaded: 53.1 at 4K, 19.2 at
204K. Files: `results/benchy-gemma26-drafter.md`,
`results/server-benchy-gemma26-drafter.log`,
`results/benchy-gemma26-drafter-vm.log`.
Deviation: `vm_stat` wired pages read about 26280 MB at the 196608
cell, above the 25000 wired-limit target. Swap held flat at 447.62 MB
with no growth across all three depths; the 197K cell sits well above
the 8 tok/s floor on real text.

## `sweep-qwen36-mlx`

`mlx-community/Qwen3.6-35B-A3B-4bit`, `mlx_lm.server`,
`--prompt-cache-size 2`, no drafter, wired 25000. `llama-benchy`
0.4.0, tokenizer `Qwen/Qwen3.6-35B-A3B`, code corpus, pp 512, tg 256,
2 runs after warmup. Depths: 4096, 39936.

| depth | benchy tok/s | sd | site tok/s | diff | swap MB |
|--:|--:|--:|--:|--:|--:|
| 4096 | 54.48 | 0.00 | 55.1 | -1.1% | no growth |
| 39936 | dead cell | — | 37.4 | — | — |

The deep cell died on `RuntimeError: [METAL] Command buffer execution
failed: Insufficient Memory (kIOGPUCommandBufferCallbackErrorOutOfMemory)`
in the generation thread, both run 1 and run 2, at prompt fill
32768/40449. The `/v1/chat/completions` endpoint kept answering
(server process alive) while the generation thread was dead, matching
the known signature. **A dead deep cell is recorded as such, and the
block is done.**
Finding: this server's real ceiling sits under 39936 (not 40982 as
last measured on 2026-09-06). Coordinator gate (2026-09-12): the dead
prompt was 40449 tokens, above the 36864 planning window, so it does
not move `qwen36_mlx_window`; that value stays 36864 for the smoke. A
death at 36864 itself, not this cell, would step the window down to
28672.
Files: `results/benchy-sweep-qwen36-mlx-nmax0.md`,
`results/server-sweep-qwen36-mlx.log`.

## `sweep-gemma26-mlx`

`mlx-community/gemma-4-26b-a4b-it-4bit`, rev `0d77464`,
`mlx_lm.server`, `--prompt-cache-size 2`, no drafter, wired 25000.
`llama-benchy` 0.4.0, tokenizer `google/gemma-4-26b-a4b-it`, code
corpus, pp 512, tg 256, 2 runs after warmup. Depths: 4096, 65536.

| depth | benchy tok/s | sd | site tok/s | diff | swap MB |
|--:|--:|--:|--:|--:|--:|
| 4096 | 49.33 | 0.15 | 51 | -3.3% | 439.62, no growth |
| 65536 | 23.43 | 0.19 | 12.8 | +83.0% | 439.62, no growth |

Both cells completed, no dead cell. The deep cell sits well above the
8 tok/s floor and well above the site's own number.
Files: `results/benchy-sweep-gemma26-mlx-nmax0.md`,
`results/server-sweep-gemma26-mlx.log`.

## `qwen36-mlx-smoke-on`

`mlx-community/Qwen3.6-35B-A3B-4bit`, `mlx_lm.server`,
`--prompt-cache-size 2`, thinking on, wired 25000, window 36864 (the
5-percent-under-ceiling planning value; the coordinator confirmed the
`sweep-qwen36-mlx` dead cell does not move it, since that prompt was
above this window).

`SMOKE-MENDEL model=mlx-community/Qwen3.6-35B-A3B-4bit level=on
task=xtend window=36864 calls=10 distinct=7 longest_run=1 loop=ok:1.00
compactions=0 splits=0 peak=3723 commits=1 clean=yes end=stop wall_s=28
verdict=pass`

**Pass.** One commit, clean tree, no repetition loop, 28 s inside the
1500 s cap. `qwen36-mlx-mendel-blind-on` runs next.
Files: `results/mendel-smoke-qwen36-mlx-on.log`,
`results/server-qwen36-mlx.log`.

## `qwen36-mlx-mendel-blind-on`

`mlx-community/Qwen3.6-35B-A3B-4bit`, `mlx_lm.server`,
`--prompt-cache-size 2`, thinking on, wired 25000, window 36864, keep
budget 8192. Started 22:28:54Z, ended 22:41:13Z. `worker.json`: loop
ok (ratio 0.62, tool call), one tooling nudge (a transient stream
error, recovered), no compaction, `end_reason` complete.

Handed to a subagent for scoring and publishing per the run's rule
(one subagent, one pass: score, `results.json`, `results.csv`,
`report.html`, commit and push to `mendel-benchmark` on branch
`benchmark`). See the handing-over section for its report.

## `gemma26-mlx-smoke-high`

`mlx-community/gemma-4-26b-a4b-it-4bit`, rev `0d77464`,
`mlx_lm.server`, `--prompt-cache-size 2`, thinking high, wired 25000,
window 65536.

`SMOKE-MENDEL model=mlx-community/gemma-4-26b-a4b-it-4bit level=high
task=xtend window=65536 calls=6 distinct=6 longest_run=1 loop=ok:1.00
compactions=0 splits=0 peak=3521 commits=0 clean=no end=toolUse
wall_s=32 verdict=fail`

**Fail.** Zero commits, tree not clean, ended on `toolUse` rather than
`stop`. The server log shows no OOM and no death signature: it logs
`WARNING - Failed to parse tool call (JSONDecodeError...) — tool text
was likely truncated mid-generation` right where the run ends. This is
a fail of the model/harness tool-call shape at this config, not a
server death. Per the run's rule, `gemma26-mlx-mendel-blind-high` does
not run.
Files: `results/mendel-smoke-gemma26-mlx-high.log`,
`results/server-gemma26-mlx.log`.
