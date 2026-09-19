# Run 26 — results

One section per block: the two ladders, the two speed curves with the
depth where each crosses the 8 tok/s floor, the calibration with its
derived budgets, the scored run with its empties and forced count, the
forced re-run, the smoke, and the blind row with its peak context and
tool-call count.

Every row of this run is served by the publisher's llama.cpp fork, in a
Metal build. The stock binary makes garbage from these files.

The run has not started.

## bonsai2-27b-pq2-mac, PQ2_0, f16 KV, `-c 262144`, wired limit 25000

Fork `prism-b10685-7dffb15`. Tool `e38c467`. Pause 60 s. Two creeps: the first to the floor, the second to find the crossing.

| depth | tok/s | wired MB | swap delta MB | compress pages | decompress pages |
|--:|--:|--:|--:|--:|--:|
| 4114 | 17.05 | 26259 | 0 | 260249 | 240538 |
| 24602 | 12.26 | 26239 | 0 | 348193 | 281722 |
| 24602 (second creep) | 12.37 | 25811 | 0 | 369279 | 603106 |
| 32818 | 11.20 | 26102 | 0 | 89369 | 89299 |
| 40982 | 9.50 | 26200 | 0 | 386423 | 331008 |
| 49198 | 8.66 | 26221 | 162 | 951388 | 902212 |
| 65578 | 7.91 | 26050 | 0 | 864805 | 836860 |

Floor 8 tok/s crosses between 40982 and 65578. Clean depth 40982. The 49198 row has swap growth. No pick.
