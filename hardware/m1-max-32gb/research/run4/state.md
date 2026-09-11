# Research run 4 — state

Created 2026-09-10 by the coordinator. Not started.

Start here: read `AGENT.md`, then `index.md`, which is the order.
Log every session below, and close each one with a handing-over
section, the same way the bench runs do.

## Values this run sets

The executor writes each value here as it measures it, with the item
that produced it.

| name | value | item |
| --- | --- | --- |
| `benchy_version` | | `benchy-ab` |
| `benchy_tokenizer` | | `benchy-ab` |
| `benchy_corpus` | | `benchy-ab` |
| `benchy_invocation` | | `benchy-ab` |
| `benchy_pass` | | `benchy-ab` |

## Session 1, 2026-09-10 (executor: Claude Fable 5.1, Mac)

Worktree `../choose-a-local-llm-research4`, branch `research4`, from
`master` at `a48f6cb`. Preflight: every line `ok`. Starting numbers:
wired 1762 MB, free 26286 MB, swap used 258 MB. Wired limit 25000.
No `llama-server`, no LM Studio, no Docker before the first server.

Installed `llama-benchy` 0.4.0 through `pipx` (Python 3.14.7).
Tokenizer files for `Qwen/Qwen3.8-27B` downloaded into the Hugging
Face cache (22 MB, tokenizer only, no weights). The quant's card names
that repo as `base_model`.

Model on disk: `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp` at
snapshot `d562806`, file `Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf`, sha256
`58fd8267...`, the same file bench13 served.

Served `-c` values come from the creeps this item compares against:
`-c 163840` for `none` (bench13 `ista-nodrafter-creep`) and
`-c 131072` for `n3` (run3 `creep-qwen38-ista-iq3s-mtp`).

Deviation: `llama-benchy` 0.4.0 has no `--warmup-runs` flag. Warmup
is on by default and `--no-warmup` turns it off, so the item's
`--warmup-runs 1` is dropped and the default warmup runs. All other
flags are as the item writes them.

### benchy-ab qwen-3.8-27b gsq-iq3s/f16/nodraft arm none ctx 160k

`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp` rev `d562806`, no
drafter, one slot, f16 KV, `-c 163840`, wired 25000. `llama-benchy`
0.4.0, tokenizer `Qwen/Qwen3.8-27B`, default corpus, pp 512, tg 256,
2 runs after 1 warmup. Started 20:03, closed 21:34.

| depth | benchy tok/s | sd | creep tok/s | diff | wired MB |
|--:|--:|--:|--:|--:|--:|
| 4k | 13.94 | 0.00 | 14.14 | -1.4% | 24500 |
| 49k | 11.36 | 0.05 | 11.51 | -1.3% | 24300 |
| 98k | 9.47 | 0.00 | 9.69 | -2.3% | 24100 |

**pass**, every cell within 5 percent of the creep.
Files: `results/benchy-none.md`, `results/server-benchy-none.log`,
`results/benchy-none-vm.log`.
Deviation: swap used 258 MB at preflight, 3776 MB after the arm. The
server keeps a prompt-cache snapshot per unique benchy prompt (3.7 GB
at 98k, log line `making room for prompt cache entry`) and evicts the
oldest; the snapshots live in host RAM and pushed the machine into
swap. Decode was flat across the three requests of every depth, so
the cells stand. A first benchy attempt was stopped after its warmup
(the session's task cap), so the server log carries 20 extra
`print_timing` lines before task 353; the arm's cells are tasks 353
to 2599. Wired returned to 1696 MB five seconds after the kill.
Finding for run 14: `--cache-ram 0` would stop the snapshots; the
creeps did not set it either, so this run kept the published shape.
