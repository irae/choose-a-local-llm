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

## `qwen38-atomicchat-iq3s-creep`

Ladder: `AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S`, f16 KV, MTP drafter on.
`-c 106496` served a real 4096-token completion (1411 tokens, EOS,
13.45 tok/s), so the ladder cleared at the starting value.

Creep ran at `-c 106496` against the depth list capped at 98304, see
`results/creep-qwen38-atomicchat-iq3s.tsv`:

4k @ 15.8 → 8k @ 15.4 → 16k @ 14.8 → 25k @ 14.2 → 33k @ 13.7 → 41k @
13.1 → 49k @ 12.7 → 66k @ 11.7 → 82k @ 11.0 → 98k @ 10.3 tok/s. No stop
condition hit (no OOM, no swap growth) — the sweep ran out of depth
list before it ran out of headroom. Ceiling: **98338 tokens**, 10.26
tok/s, wired ~24.0-24.1 GB throughout, clean the whole way.

Tool: `local-llm-eval-tools` commit `2344f00`.

## `qwen38-ista-iq3s-mtp-creep`

Ladder: `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, f16 KV,
built-in MTP head. `-c 131072` served a real 4096-token completion
(1708 tokens, EOS, 13.52 tok/s), ladder cleared at the starting value.

Creep ran at `-c 131072`, see
`results/creep-qwen38-ista-iq3s-mtp.tsv`:

4k @ 15.1 → 8k @ 13.5 → 16k @ 14.7 → 24k @ 14.2 → 33k @ 13.7 → 41k @
13.2 → 49k @ 12.7 → 66k @ 11.8 → 82k @ 11.0 → 98k @ 10.3 → 115k @ 9.7
→ 131k @ 9.1 tok/s. Stop: swap grew 429 MB at depth 131098 (mem
verdict). Clean ceiling: **114718 tokens**, 9.67 tok/s, wired ~24.2 GB
throughout.

Tool: `local-llm-eval-tools` commit `2344f00`.

## The three EvalPlus smokes

Control (`bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, f16, `-c 49152`, medium,
the row we serve today): 4/4 passed, 0 empty, 3506/8192 tokens.

| build | passed | empty | tokens | verdict |
| --- | --: | --: | --: | --- |
| unsloth q3kxl (`-c 49152`) | 4/4 | 0 | 2804/8192 | level |
| atomicchat iq3s (`-c 98304`) | 4/4 | 0 | 2668/8192 | level |
| ista iq3s-mtp (`-c 114688`) | 4/4 | 0 | 2598/8192 | level |

### `qwen38-evalplus-gate`

| build | pass count | mendel |
| --- | --: | --- |
| unsloth q3kxl | 4/4 | run |
| atomicchat iq3s | 4/4 | run |
| ista iq3s-mtp | 4/4 | run |

All three level with the control row and none returned an empty
completion. All three go on to their Mendel smoke.

Tool: `benchmarks/evalplus-smoke.py`, budget from
`benchmarks/calibration-qwen38-gguf-medium.json` (8192, both sides).
Needed `openai` and `evalplus` installed; put them in a venv at
`~/.venvs/local-llm-bench` rather than touching the Homebrew Python.

## The three creeps, side by side

| build | ceiling | tok/s at ceiling | stop reason |
| --- | --: | --: | --- |
| unsloth q3kxl | 49198 | 12.45 | mem, swap +3 MB at 65578 |
| atomicchat iq3s | 98338 | 10.26 | none, ran off end of depth list |
| ista iq3s-mtp | 114718 | 9.67 | mem, swap +429 MB at 131098 |

## The two gates

`qwen38-creep-gate` and `qwen38-evalplus-gate` each write their table
here, with one line per build, the builds they passed as well as the
builds they stopped.

### `qwen38-creep-gate`

Reference: 49152 tokens (deepest clean depth this machine has measured
for Qwen3.8 at f16). Floor: 20 percent under it, 39322 tokens.

| build | clean depth | reference | ratio | evalplus |
| --- | --: | --: | --: | --- |
| unsloth q3kxl | 49198 | 49152 | 100.1% | run |
| atomicchat iq3s | 98338 | 49152 | 200.1% | run |
| ista iq3s-mtp | 114718 | 49152 | 233.4% | run |

All three clear the floor. All three go on to their EvalPlus smoke.
