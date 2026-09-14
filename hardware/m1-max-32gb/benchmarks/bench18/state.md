# Run 18 — state

The run's log. The runner writes the medium form of every block here
at block close (`docs/methodology/status-lines.md`), and every value a
block assigns, one line per value, with its source.

## Values

- preflight start: wired 1954 MB, free 19818 MB, swap used 179 MB. Balloon needed (source: `tools/preflight.sh`, 2026-09-14).
- `qwen38_unsloth_path`: `/Users/irae/.cache/huggingface/hub/models--unsloth--Qwen3.8-27B-GGUF/snapshots/4ca720788d1e01f1bff70c033e0d0028fd02e502/Qwen3.8-27B-UD-IQ3_S.gguf`
- `qwen38_unsloth_rev`: `4ca720788d1e01f1bff70c033e0d0028fd02e502` (matches the AGENT.md expected revision)
- `qwen38_unsloth_sha256`: `d847e2c1e4aa276e4b7b8e9ad7628050e61e165d49ab995407bc36677a6f3864` (matches the Linux box's file exactly, same file)
- `creep_tool_rev`: `e38c467` (`local-llm-eval-tools`, already up to date)
- `benchy_version`: `llama-benchy 0.4.0` (pipx, Python 3.14.7), read from run 16's state at `hardware/m1-max-32gb/research/run4/state.md`
- `benchy_corpus`: `results/corpus-mendel-js.txt`, 152099 Qwen tokens, sha256 `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`, served at `http://127.0.0.1:8089/corpus-mendel-js.txt`
- `benchy_invocation`: as in run 16's state, `--book-url http://127.0.0.1:8089/corpus-mendel-js.txt --pp 512 --tg 256 --runs 2`, server flag `--cache-ram 0` for measurement runs
- pi entry `qwen3.8-27b-iq3s` added to `~/.pi/agent/models.json`, provider `llama`, copied from `qwen3.8-27b-ista` (contextWindow 147456 is a placeholder). Verified with `pi --list-models | grep qwen3.8`.
- Every Qwen3.8 entry's `thinkingLevelMap` set to `{off: null, minimal: null, low: "low", medium: "medium", high: "medium", xhigh: "xhigh", max: "xhigh"}`. Every other reasoning entry of provider `llama` remapped down by the same rule (binary off/high models: off/minimal/low/medium → off, high/xhigh/max → high). Entries with no `thinkingLevelMap` (`qwen3.6-27b`, `gemma-4-12b-2x`, `bonsai-prism`, `bonsai-prism-f16`) left untouched. Before/after snapshots: `/tmp/pi_map_before.json`, `/tmp/pi_map_after.json` (not committed, local only).
- `~/code/mendel-benchmark` fast-forwarded to `origin/benchmark` (fe692ec → 0ab06c6). `gh auth status` passes (account irae).
- Note: origin carries a remote branch `qwen3.8-27b-iq3s-xhigh-guided-v3-issue-13-interrupted1`, meaning a prior attempt at this exact model's guided row was interrupted. Not investigated yet; the runbook's own worker naming picks a fresh branch when none exists, so this is only a flag for later, not a blocker.

## Blocks

### machine-setup

The model file loaded clean through llama-server with no `Insufficient Memory`, no Metal OOM, no 500 (log `results/server-download.log`). Server stopped after load. Sweep tool, benchy values, pi entry and thinking maps, and the mendel-benchmark repo are all in place; `gh auth status` passes.
Deviation: none.

## Handing over

Not started.
