# Run 14 — state

Created 2026-09-10 by the coordinator. Not started.

Start here: read `AGENT.md`. The list at the top of that file is the
order. Log every session below, and close each one with a
handing-over section.

## Values this run sets

The runner writes each value here as it measures it, with the block
that produced it.

| name | value | block |
| --- | --- | --- |
| `benchy_version` | `llama-benchy 0.4.0` (pipx, already installed) | `benchy-gate`, from research run 4 |
| `benchy_tokenizer` | `Qwen/Qwen3.8-27B` (already in the Hugging Face cache) | `benchy-gate`, from research run 4 |
| `benchy_corpus` | code, `hardware/m1-max-32gb/research/run4/results/corpus-mendel-js.txt`, 152099 Qwen tokens, sha256 `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`, served with `python3 -m http.server 8089 --bind 127.0.0.1` from that directory and passed as `--book-url http://127.0.0.1:8089/corpus-mendel-js.txt` (benchy fetches over HTTP; a local path or `file://` does not work) | `benchy-gate`, from research run 4 |
| `benchy_invocation` | `llama-benchy --base-url http://127.0.0.1:8081/v1 --model <alias> --tokenizer Qwen/Qwen3.8-27B --book-url http://127.0.0.1:8089/corpus-mendel-js.txt --pp 512 --tg 256 --depth <depths> --runs 2 --post-run-cmd 'sleep 60; vm_stat \| head -12 >> <vm log>; sysctl vm.swapusage >> <vm log>' --format md --save-result <result md>` (no `--warmup-runs` flag in 0.4.0; the default warmup is one request per test). Every benchy server carries `--cache-ram 0` for the measurement only. | `benchy-gate`, from research run 4 |
| `benchy_pass` | `yes` | `benchy-gate`, from research run 4 |
| `qwen36_f16_nodrafter_wired` | | `benchy-qwen36-f16-nodrafter` |
| `qwen36_q8_82k_toks` | 13.01 tok/s @ 82K, 0.60–0.62 acceptance | `benchy-qwen36-q8-drafter` |
| `qwen36_sampling` | | `qwen36-mendel-blind-off` |
| `qwen38_bartowski_sampling` | | `qwen38-bartowski-mendel-xhigh` |

## Session 1, 2026-09-11 (runner: Claude Sonnet 5, Mac)

Worktree `../choose-a-local-llm-run14`, branch `run14`, from `master`
at `d7dbfd5`. Preflight: every line `ok`. Starting numbers: wired 1798
MB, free 21177 MB, swap used 437 MB. Wired limit 25000. Memory line:
"balloon needed" (free under 25600 MB threshold) — no balloon taken
yet; the model under test will drive context up during its own block.
No `llama-server`, no LM Studio, no Docker before the first server.

`benchy-gate`: read research run 4's `state.md`. `benchy_pass` is
`yes`, so the four benchy values above are copied in and the three
benchy blocks may run.

### benchy-qwen36-f16-nodrafter — running

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`, `--no-mmproj`, f16 KV, no drafter, one slot, `-c 40960`, wired 25000. Verified with a real 400-token completion before the sweep, not a one-token probe. Corpus HTTP server on 8089. `llama-benchy` 0.4.0, tokenizer `Qwen/Qwen3.8-27B`, code corpus, pp 512, tg 256, depths 4096 and 40960, 2 runs. Started 00:14.

| depth | tok/s | wired MB | site tok/s | diff |
|--:|--:|--:|--:|--:|
| 4k | - | - | 69.1 | - |
| 40960 | - | - | 52.6 | - |

| depth | tok/s | wired MB | site tok/s | diff |
|--:|--:|--:|--:|--:|
| 4k | 49.80 ± 0.41 | 24019 | 69.1 | -28.0% |
| 40960 | — (HTTP 400) | - | 52.6 | - |

**window**, partial. Files: `results/benchy-qwen36-f16-nodrafter.md`, `results/server-benchy-qwen36-f16-nodrafter.log`.
Deviation 1: the first launch passed `--depth 4096,40960` (comma-joined) and `llama-benchy` 0.4.0 rejects that: it wants space-separated values. The tool exited at once with no request sent, so nothing was measured on the bad invocation. Restarted with `--depth 4096 40960`; the server was never touched and stayed up the whole time.
Deviation 2, stop-and-ask candidate: the `depth=40960` cell failed all three requests (warmup + 2 runs), HTTP 400, "request (41473 tokens) exceeds the available context size (40960 tokens)". `-c 40960` is the runbook's own derived ceiling, but benchy's request at a given depth adds its own pp/tg tokens on top of the depth, so a request AT the ceiling depth cannot fit inside a server serving exactly that ceiling. The `4096` cell measured clean: 49.80 ± 0.41 tok/s, 28.0% under the site's 69.1 (with-drafter, with-artifact) figure — a real gap, since this arm has no drafter and a different KV setup than that published row's nearest pair.
My candidate answer: re-run the deep cell at a depth with headroom below the ceiling, e.g. `depth=40448` (`-c` minus roughly the pp+expected tg span), so the request fits inside `-c 40960` while still reading close to the deep end of the window. I did not re-run this on my own judgment; moving on to the next block and coming back to this one once the coordinator confirms the depth (or a different `-c`) to use.
Server stopped, wired recovered to baseline before the next block started.

Coordinator answered the stop-and-ask: re-run the deep cell at depth
**39936**, not my candidate 40448. Benchy adds pp 512 plus tg 256 plus
template tokens on top of the depth: 40448 gives 41216 and still fails;
39936 gives 40704 and fits under `-c 40960`. Record it as "39936, the
deepest benchy request that fits `-c 40960`" and pair it with the
site's 41K cell. Queued: retry this cell once the current server
(`benchy-qwen36-q8-drafter`) finishes, since a different server config
is needed and only one server runs at a time.

### benchy-qwen36-q8-drafter — running

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`, `--no-mmproj`, q8_0 KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`, one slot, `-c 98304`, wired 25000. Verified with a real 400-token completion before the sweep. Corpus HTTP server on 8089. `llama-benchy` 0.4.0, tokenizer `Qwen/Qwen3.8-27B`, code corpus, pp 512, tg 256, depths 4096, 49152, 81920 (`--depth` space-separated), 2 runs. Started 00:59.

| depth | tok/s | wired MB | site tok/s | diff | acceptance |
|--:|--:|--:|--:|--:|--:|
| 4k | 43.68 ± 0.82 | 25628 | 36.5 | +19.7% | 0.60–0.85 (last 2 runs) |
| 49152 | 19.23 ± 0.87 | 25628 | 14.3 | +34.5% | 0.54–0.59 |
| 81920 | 13.01 ± 0.16 | 25628 | 9.24 | +40.8% | 0.60–0.62 |

Closed 27:24 elapsed. The 82K cell reads 13.01 tok/s on real text,
above the 8 tok/s floor by a wide margin: the row's window still holds.
Swap used stayed flat (437 → 421 MB), no growth during the sweep.
Files: `results/benchy-qwen36-q8-drafter.md`, `results/server-benchy-qwen36-q8-drafter.log`, `results/benchy-qwen36-q8-drafter-vm.log`.
Deviation: none. Sets `qwen36_q8_82k_toks` = 13.01 tok/s @ 82K, 0.60–0.62 acceptance.

### benchy-qwen36-f16-nodrafter retry, deep cell — running

Same server config as the first attempt (rev `5bc3e23`, `--no-mmproj`, f16 KV, no drafter, one slot, `-c 40960`, wired 25000), re-served fresh and verified with a real 400-token completion. Corpus HTTP server on 8089. `llama-benchy` 0.4.0, depth **39936** only (the coordinator's value: `-c` minus pp 512, tg 256 and template tokens, the deepest request that fits), 2 runs. Started 01:43.

still running.
Files: `results/benchy-qwen36-f16-nodrafter-retry.md`, `results/server-benchy-qwen36-f16-nodrafter-retry.log`.
Deviation: none.

