# Ternary Bonsai-2-27B on M1 Max 32 GB — prism-llama benchmarks

Builds: prism-ml PQ2_0 and PTQ1_0, revision `6ed5e12`. Backend: the
PrismML llama.cpp fork (`prism-llama`), release `prism-b10685-7dffb15`,
commit `7dffb158d`, Metal build. The stock llama.cpp binary does not
serve these files.

The full data of every measurement of this model on this machine lands
here as the runs close. Raw evidence:
`hardware/kamaji/benchmarks/bench26/` in the repo. The report page:
[Ternary Bonsai-2-27B](../reports/bonsai-2-27b.md).

## Ladder, 2026-09-18

f16 KV only: a quantized cache costs this machine more than it returns.
Both files load at `-c 262144`, the trained context. The window comes
from the sweep, not from the load.

## Decode speed against used context

Read with the context-creep tool at wired limit 25000, one context,
60-second pause. A row with swap growth is not clean.

| depth | PQ2_0 | PTQ1_0 |
|--:|--:|--:|
| 4114 | 17.05 | 17.86 |
| 24602 | 12.26 | 16.05 |
| 32818 | 11.20 | 15.28 |
| 40982 | 9.50 | 14.71 |
| 49198 | 8.66, swap +162 MB | 14.12 |
| 57362 | | 13.48 |
| 65578 | 7.91 | 13.05 |
| 98338 | | 11.37 |
| 131098 | | 10.07 |
| 163858 | | 9.07 |
| 196618 | | 8.18, swap +130 MB |

Deepest clean depth: 40982 for PQ2_0, 163858 for PTQ1_0. PTQ1_0 is the
served pack.
