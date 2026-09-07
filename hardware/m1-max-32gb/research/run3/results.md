# Research run 3 — results

Every number this run measured, with the exact command that produced
it. Nothing here reaches the site: the coordinator decides which
candidate becomes a bench item, and the bench run publishes.

Raw files go in `results/`: one server log and one creep file per
item, named by the item's mnemonic.

## `qwen38-unsloth-q3kxl-creep`

Ladder: `unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL`, f16 KV, MTP drafter on,
real 4096-token completions at each rung.

| `-c` | result |
| --- | --- |
| 114688 | served, 1849 tokens, EOS, 13.48 tok/s |
| 122880 | served, 284 tokens, EOS, 12.85 tok/s |
| 131072 | served, 1849 tokens, EOS, 13.55 tok/s |

Ladder stopped at 131072, the top of the creep tool's own depth list.
Creep ran at `-c 131072`, see `results/creep-qwen38-unsloth-q3kxl.tsv`:

4k @ 14.4 → 8k @ 14.1 → 16k @ 12.2 → 24k @ 13.0 → 32k @ 12.1 → 41k @
10.9 → 49k @ 12.5 → 65k @ 11.6 tok/s. Stop: swap grew 3 MB at depth
65578 (mem verdict, not a model limit). Clean ceiling: **49198
tokens**, 12.45 tok/s, wired ~24.5-25.2 GB throughout.

Tool: `local-llm-eval-tools` commit `2344f00`.

## The two gates

`qwen38-creep-gate` and `qwen38-evalplus-gate` each write their table
here, with one line per build, the builds they passed as well as the
builds they stopped.
