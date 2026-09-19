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

## bonsai2-27b-ptq1-mac, PTQ1_0, f16 KV, `-c 262144`, wired limit 25000

Fork `prism-b10685-7dffb15`. Tool `e38c467`. Pause 60 s. Two creeps joined at 65578.

| depth | tok/s | wired MB | swap delta MB | compress pages | decompress pages |
|--:|--:|--:|--:|--:|--:|
| 4114 | 17.86 | 26011 | 0 | 16621 | 5729 |
| 24602 | 16.05 | 25981 | 0 | 77050 | 35803 |
| 32818 | 15.28 | 25952 | 0 | 330532 | 267649 |
| 40982 | 14.71 | 25924 | 0 | 162046 | 121770 |
| 49198 | 14.12 | 25887 | 0 | 130462 | 106150 |
| 57362 | 13.48 | 25842 | 0 | 183907 | 158374 |
| 65578 | 13.05 | 25551 | -8 | 154539 | 78101 |
| 65578 (control) | 13.02 | 25529 | 0 | 350455 | 621510 |
| 98338 | 11.37 | 25921 | -8 | 165357 | 146507 |
| 131098 | 10.07 | 25908 | -8 | 177723 | 142885 |
| 163858 | 9.07 | 25484 | -49 | 798556 | 747908 |
| 196618 | 8.18 | 26861 | 130 | 355239 | 334796 |

The 196618 row has swap growth and stopped the creep. Clean depth 163858. No pick.

## bonsai2-budget-xhigh-mac

PTQ1_0, f16 KV, `-c 32768`, xhigh, fork `prism-b10685-7dffb15`, wired limit 25000. Think budget 16056, answer budget 2048, `max_tokens` 18104, margin 1.5. Server sampling: temperature 1.0, top_k 20, top_p 0.95, min_p 0.05; EvalPlus sends temperature 0.

| metric | value |
|---|--:|
| HumanEval base | 0.988 |
| HumanEval plus | 0.939 |
| empty | 0/164 |
| forced | 7/164 |
| wall | 482.9 min (337 run + 145.9 calibration) |

Forced: HumanEval/32, /39, /80, /99, /129, /137, /145. Parts: 07:14Z to 12:51Z, no crash.

## bonsai2-forced-rerun-mac

Natural re-run at 30000 of the 7 forced answers' failures (4 problems), PTQ1_0, f16 KV, `-c 32768`, xhigh, no reasoning flag. Wall 121 min, one part, 13:06Z to 15:07Z.

| task_id | cell | forced tokens | natural finish | natural tokens |
|---|---|--:|---|--:|
| HumanEval/32 | forced-fail-loop | 17107 | length | 30000 |
| HumanEval/39 | forced-fail-loop | 16381 | length | 30000 |
| HumanEval/80 | forced-pass | 16272 | | |
| HumanEval/99 | forced-fail-loop | 16268 | length | 30000 |
| HumanEval/129 | forced-pass | 16788 | | |
| HumanEval/137 | forced-pass | 16389 | | |
| HumanEval/145 | forced-fail-loop | 16268 | length | 30000 |

Summary: forced-pass 3, forced-fail-late 0, forced-fail-loop 4, forced-fail-wrong 0. Corrected think budget: unchanged, no late answer.
