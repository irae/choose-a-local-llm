# T0.4 — prompt-cache health on local backends

Run 2, session 1, 2026-09-04. Section G. Tool: `cache-share.py` in this
folder.

## The field exists on every backend, with the same name

| Backend | Field | Verified how |
| --- | --- | --- |
| llama-server 0.3.0 | `usage.prompt_tokens_details.cached_tokens` | Live response during the context ramp. |
| `mlx_lm.server` 0.31.3 | `usage.prompt_tokens_details.cached_tokens` | `server.py` line 1344 sets it whenever `prompt_cache_count >= 0`. |
| LM Studio | same field | The LM Studio sweep already reads it. |

So no server work is needed. One reader covers all three, because all
three answer with the OpenAI field.

`mlx_lm.server` also logs the cache size itself: `_log_cache_stats`
writes `Prompt Cache: N sequences, X GB` and a per-type breakdown to the
server log. That is a second, independent signal, and it is the one that
would show a cache growing without bound.

## Better still: pi already records it, so a run needs no extra probe

pi's usage records carry `cacheRead`, filled from the same field. The
per-turn numbers are in `<out>-events.jsonl`, which every `run-pi-rpc.mjs`
run writes. Measured on the T1.1 llama-server replay while it ran:

```
turn  prompt   fresh   cached  share
   1    4145    4145        0    0.0%
   2    4496      74     4422   98.4%
   5    5862     129     5733   97.8%
  10    9192    1747     7445   81.0%
  14   10838      88    10750   99.2%

run cache share: 90.8% (91938 of 101306 prompt tokens)
```

Turn 1 is a cold cache and is always 0 percent. From turn 2 the config
serves 81-99 percent of each prompt from cache. That is a healthy local
serving config, and it is now measurable in the first minutes of a run
rather than after 300.

## Proposed alert rule

**After turn 3, a cache share below 20 percent is a broken serving
config.** Report it, stop, and fix the config before the run continues;
do not score the model on it.

The threshold is deliberately far below anything a working config
produces. A healthy run sits above 80 percent from turn 2. A config that
re-reads the whole context every turn sits near 0 percent. There is no
middle ground to argue about, so a low threshold costs nothing and
avoids false alarms after a compaction, where one turn legitimately
drops.

`cache-share.py` implements exactly this rule and prints the alert line.
Both the threshold and the "after turn N" grace period are flags.

## One thing this turned up for the parked list

`peak_context` is recorded per turn after all. The prompt-token column
above IS the context at each cycle, and it comes from a file every pi
run already writes. Run 1 could not prove `peak_context` for existing
rows because those runs' logs are gone — nine of seventeen Mendel rows
have no log left. That is a missing-evidence problem, not a
missing-instrument problem. Any FUTURE row can carry a proved
`peak_context` with no new tooling. The decision about existing rows
stays with the owner, parked for run 3.
