# Research run 4 — state

Created 2026-09-10 by the coordinator. Session 1 ran 2026-09-10,
19:55 to 22:45, and closed the one item.

Start here: read `AGENT.md`, then `index.md`, which is the order.
Log every session below, and close each one with a handing-over
section, the same way the bench runs do.

## Values this run sets

The executor writes each value here as it measures it, with the item
that produced it.

| name | value | item |
| --- | --- | --- |
| `benchy_version` | `llama-benchy 0.4.0` (pipx, Python 3.14.7) | `benchy-ab` |
| `benchy_tokenizer` | `Qwen/Qwen3.8-27B` (Hugging Face repo, cached locally) | `benchy-ab` |
| `benchy_corpus` | default (benchy's Sherlock Holmes text, 144480 tokens) | `benchy-ab` |
| `benchy_invocation` | `llama-benchy --base-url http://127.0.0.1:8081/v1 --model qwen3.8-27b --tokenizer Qwen/Qwen3.8-27B --pp 512 --tg 256 --depth <depths> --runs 2 --post-run-cmd 'sleep 60; vm_stat \| head -12 >> <vm log>' --format md --save-result <result md>` (no `--warmup-runs`: not a flag in 0.4.0, default warmup is one request per test) | `benchy-ab` |
| `benchy_pass` | `no`: the `n3` cell at 98k read 6.03 ± 0.37 tok/s at 41 to 51 percent acceptance, not near 7.89 at 60 to 80. The `none` arm passed every cell within 2.3 percent. The tool tracks acceptance; the default corpus drafts worse than the agent runs. | `benchy-ab` |

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

### benchy-ab qwen-3.8-27b gsq-iq3s/f16 arm n3 ctx 128k

`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp` rev `d562806`, MTP
n-max 3, one slot, f16 KV, `-c 131072`, wired 25000. `llama-benchy`
0.4.0, tokenizer `Qwen/Qwen3.8-27B`, default corpus, pp 512, tg 256,
2 runs after 1 warmup. Started 21:37, closed 22:39.

| depth | benchy tok/s | sd | creep tok/s | real-prompt cell | acceptance (runs) | acceptance (warmup) | wired MB |
|--:|--:|--:|--:|--:|--:|--:|--:|
| 98k | 6.03 | 0.37 | 10.30 | 7.89 | 41.3%, 51.3% | 69.6% | 23400 |

**fail** on the item's `n3` criterion: not near 7.89, acceptance under
the 60 to 80 percent band. The warmup request, inside the band at
69.6 percent, read 7.80. Per-request tok/s: 7.80, 5.67, 6.40.
Files: `results/benchy-n3.md`, `results/server-benchy-n3.log`,
`results/benchy-n3-vm.log`.
Deviation: none. Swap used 906 to 922 MB across the arm, no growth.
Wired returned to 1658 MB five seconds after the kill.

## Handing over, session 1, 2026-09-10 22:45

What ran: the one item, `benchy-ab`, both arms, in order. The `none`
arm passed on all three cells (within 2.3 percent of the creep). The
`n3` arm failed the item's criterion: 6.03 ± 0.37 tok/s at 41 to 51
percent acceptance, against 7.89 at 60 to 80. Verdict line in
`results.md`: **fail**. The tool did not fail: the drafter cell
tracks acceptance request by request, and the memorised-corpus case
(10.30 at over 95 percent) did not occur. The default corpus makes
the drafter miss more than the agent runs do.

Gate for the coordinator: whether `fail` on the corpus counts as
fail on the tool for run 14's three benchy blocks. Candidate answer:
run 14's benchy blocks wait, as the item says, until the coordinator
either accepts benchy's default-corpus number as the drafter's
prose-workload speed, or names a corpus rule (a code text through
`--book-url`, one re-run of this cell) for research to test.

Machine state: no `llama-server`, no `mlx_lm`, no `llama-benchy`
process. Wired 1658 MB. Swap used 906 MB (258 MB at preflight; the
growth happened on the `none` arm and stayed). Wired limit 25000. LM
Studio not started. `llama-benchy` 0.4.0 stays installed under
`pipx`; the `Qwen/Qwen3.8-27B` tokenizer files stay in the Hugging
Face cache (22 MB). Nothing else installed.

Evidence: `results/` on branch `research4`, archived with
`tools/archive-evidence.sh` to
`~/.local/share/choose-a-local-llm/evidence/research4/`.
