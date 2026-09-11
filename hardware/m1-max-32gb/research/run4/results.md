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

### Arm `n3`: `--spec-type draft-mtp --spec-draft-n-max 3`, `-c 131072`, depth 98304

Server: the published command shape with the two drafter flags.
Creep pair: run3 `creep-qwen38-ista-iq3s-mtp.tsv` (2026-09-08), 10.30
at 98338 with 100 percent acceptance; the real-prompt cell of the
drafter table, 7.89 at 60 to 80 percent. Benchy ran 21:37 to 22:39.
The post-run command also appended `sysctl vm.swapusage` on this arm.

| depth | server prompt | benchy tok/s | sd | creep tok/s (depth) | diff | real-prompt cell | diff | acceptance |
|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| 98304 | 98817 | 6.03 | 0.37 | 10.30 (98338) | -41.5% | 7.89 | -23.6% | 41.3% and 51.3% (runs), 69.6% (warmup) |

Per request from the server log (`eval time`, 256 tokens, then
`draft acceptance`):

| request | tok/s | acceptance | mean draft len |
|---|--:|--:|--:|
| warmup, task 104 | 7.80 | 0.696 (172/247) | 3.07 |
| run 1, task 239 | 5.67 | 0.413 (141/341) | 2.24 |
| run 2, task 405 | 6.40 | 0.513 (154/300) | 2.54 |

The probe before benchy, an 80-token code prompt with 200 tokens out,
read 10.46 tok/s at 0.524 acceptance (task 0).

Prefill 87.2 tok/s per request, the full depth every time. Memory:
wired 23.3 to 23.4 GB, swap used 922 MB at the first sample and
906 MB at the last, so no swap growth on this arm.

Reading. The memorised-corpus case did not occur: no request reached
95 percent acceptance and no cell read near the creep's 10.30. The
tool reads the drafter the way the item wants, and the speed tracks
the acceptance request by request: 7.80 at 70 percent, 6.40 at 51,
5.67 at 41. The one request inside the 60 to 80 percent band read
7.80, which is the real-prompt cell's 7.89 within 1.2 percent. But
that request is the warmup, which benchy leaves out of its result,
and the two counted runs sat at 41 and 51 percent, under the band.
The default corpus makes this model draft worse than the agent runs
do, so the benchy cell reads 6.03, under the no-drafter 9.47 at the
same depth.

Files: `results/benchy-n3.md`, `results/benchy-n3.stdout.log`,
`results/benchy-n3-vm.log`, `results/server-benchy-n3.log`.

### Verdict

**fail**, on the `n3` criterion: 6.03 ± 0.37 tok/s at 41 to 51
percent acceptance is not near 7.89 at 60 to 80 percent. The `none`
arm passes on all three cells. The failing criterion is the corpus's
acceptance, not the tool: the tool's readings track acceptance, and
the corpus-memorised failure mode did not occur.

### Arm `n3`, code corpus: same server plus `--cache-ram 0`, depth 98304

Gate answer from the coordinator (2026-09-10 22:40): the tool passed,
the prose corpus did not; re-run the `n3` 98k cell once with a code
corpus, serve with `--cache-ram 0` (measurement runs only, the
published command does not change), pass if the counted requests read
acceptance between 60 and 80 percent and the mean lands within 10
percent of 7.89.

Corpus: the `.js` files under `~/code/mendel`, path order, without
`node_modules`, `.git`, lockfiles and minified files, each file
preceded by a `// file: <path>` line, cut after the file that crossed
150K tokens. 288 of 392 files, 152099 tokens by the Qwen tokenizer,
613339 bytes, sha256
`f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`.
Builder: `results/build-corpus.py`; file: `results/corpus-mendel-js.txt`.
`--book-url` goes through `requests.get`, so a local path or a
`file://` URL does not work; `python3 -m http.server 8089 --bind
127.0.0.1` in `results/` served it and
`--book-url http://127.0.0.1:8089/corpus-mendel-js.txt` worked.
Benchy strips nothing from a text without the Gutenberg marker.

Server: the `n3` command plus `--cache-ram 0`. The log has no
`prompt cache` line on this arm. Benchy ran 22:45 to 23:47. The
probe before benchy (80-token code prompt, 200 out) read 12.39 tok/s
at 0.682 acceptance.

| depth | corpus | server prompt | benchy tok/s | sd | real-prompt cell | diff | acceptance (runs) | acceptance (warmup) | flags |
|--:|---|--:|--:|--:|--:|--:|--:|--:|---|
| 98304 | prose workload (default book) | 98817 | 6.03 | 0.37 | 7.89 | -23.6% | 41.3%, 51.3% | 69.6% | published shape |
| 98304 | code (mendel `.js`) | 98815 | 5.62 | 0.18 | 7.89 | -28.8% | 38.3%, 43.1% | 32.0% | `--cache-ram 0` |

Per request on the code corpus (`eval time`, 256 tokens, then
`draft acceptance`):

| request | tok/s | acceptance | mean draft len |
|---|--:|--:|--:|
| warmup, task 115 | 4.96 | 0.320 (124/387) | 1.95 |
| run 1, task 298 | 5.44 | 0.383 (136/355) | 2.14 |
| run 2, task 469 | 5.79 | 0.431 (143/332) | 2.29 |

Prefill 87.2 tok/s per request. Memory: wired 23.4 to 23.6 GB, swap
used 874 MB at the first sample and 762 MB at the last, no growth.

Reading. The code corpus did not lift acceptance; it fell from 41 to
51 percent to 38 to 43. Both corpora sit well under the 60 to 80
band, while the shallow probes on the same servers read 52 to 68
percent. The 7.89 cell this band comes from
(bench13 `ista-nmax-deep`) was one 256-token completion at
temperature 0 on a code task. Benchy passes no temperature, so every
benchy request samples at the server's default, and a sampled token
is one the drafter guessed less often. The band was set from an
unsampled shot; benchy reads the sampled workload, which is the one
the agent runs serve (no Mendel run ever passed a temperature). The
tool reads what it is pointed at. Whether the target band is the
right one is the coordinator's call; one temperature-0 benchy cell
through `--extra-body` would confirm the cause, which this item does
not allow.

Files: `results/benchy-n3-code.md`, `results/benchy-n3-code.stdout.log`,
`results/benchy-n3-code-vm.log`, `results/server-benchy-n3-code.log`,
`results/corpus-mendel-js.txt`, `results/build-corpus.py`.

### Verdict, after the code-corpus cell

**fail**, on the coordinator's cell criterion: 5.62 ± 0.18 tok/s at
38 to 43 percent acceptance, not within 10 percent of 7.89 at 60 to
80. The `none` arm stands as a pass. The prose cell stays as its own
row above.
