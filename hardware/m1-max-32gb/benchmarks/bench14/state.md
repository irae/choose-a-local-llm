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
| `qwen36_q8_82k_toks` | | `benchy-qwen36-q8-drafter` |
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

