# Run 14 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence.

A benchy table has one row per depth: depth, benchy tok/s, its
standard deviation across the repeats, the site's current tok/s at
the nearest depth, the difference in percent, and the draft
acceptance read from the server log. A cell without acceptance is not
a drafter measurement. A table carries no pick.

## benchy-qwen36-f16-nodrafter

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`, `--no-mmproj`, f16 KV, no drafter, one slot, `-c 40960`, wired 25000.

```
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 40960 \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 --offline
```

The `40960` cell failed at that exact depth: a benchy request adds
pp/tg tokens on top of the depth, so a request at the ceiling depth
does not fit inside a server serving exactly that ceiling (HTTP 400,
"exceeds the available context size"). Retried at depth 39936, the
deepest request that fits `-c 40960`, on the coordinator's answer.

| depth | benchy tok/s | sd | site tok/s | diff | acceptance |
|--:|--:|--:|--:|--:|--:|
| 4096 | 49.80 | 0.41 | 69.1 | -28.0% | — (no drafter) |
| 39936 | 38.26 | 0.01 | 52.6 (41K) | -27.3% | — (no drafter) |

Files: `results/benchy-qwen36-f16-nodrafter.md`, `results/benchy-qwen36-f16-nodrafter-retry.md`, `results/server-benchy-qwen36-f16-nodrafter.log`, `results/server-benchy-qwen36-f16-nodrafter-retry.log`.

## benchy-qwen36-q8-drafter

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`, `--no-mmproj`, q8_0 KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`, one slot, `-c 98304`, wired 25000.

```
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 --cache-ram 0 \
  --jinja --port 8081 --offline
```

| depth | benchy tok/s | sd | site tok/s | diff | acceptance |
|--:|--:|--:|--:|--:|--:|
| 4096 | 43.68 | 0.82 | 36.5 | +19.7% | 0.60–0.85 |
| 49152 | 19.23 | 0.87 | 14.3 | +34.5% | 0.54–0.59 |
| 81920 | 13.01 | 0.16 | 9.24 | +40.8% | 0.60–0.62 |

The 82K cell reads 13.01 tok/s on real text, above the 8 tok/s floor
by a wide margin: the row's window still holds.
Files: `results/benchy-qwen36-q8-drafter.md`, `results/server-benchy-qwen36-q8-drafter.log`, `results/benchy-qwen36-q8-drafter-vm.log`.

## benchy-qwen38-bartowski-drafter

`bartowski/Qwen3.8-27B-GGUF:Q4_K_M` rev `f0eec4a`, `--no-mmproj`, f16 KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`, one slot, `-c 73728`, wired 25000. Tokenizer `Qwen/Qwen3.8-27B`, this build's own base model, so `benchy_tokenizer` from research run 4 applies as-is.

```
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 --offline
```

| depth | benchy tok/s | sd | site tok/s | diff | acceptance |
|--:|--:|--:|--:|--:|--:|
| 4096 | 11.77 | 1.09 | 20.0 | -41.2% | 0.46–0.54 |
| 65536 | 8.57 | 1.39 | 13.7 | -37.4% | 0.37–0.63 |

Wired 25022 MB, swap flat (437 → 421 MB across the session, no growth).
Files: `results/benchy-qwen38-bartowski-drafter.md`, `results/server-benchy-qwen38-bartowski-drafter.log`.
