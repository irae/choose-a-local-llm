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
