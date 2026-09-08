# Run 12 — state

Started 2026-09-08. `tool-check` pinned `local-llm-eval-tools` at
`2344f00`. Wired limit confirmed 25000 (per `AGENT.md`; the machine
file's 24000/22000 is stale, a known false positive on preflight).

`gemma12_2x_clean` = **81958** tokens per slot (redo, creep-judged,
2026-09-08). The coordinator caught that the first reading (8222 at
`-c 770048`) measured a load ceiling, not a window: that `-c`'s KV
allocation alone left ~68 MB free, so its creep mem-stopped almost
immediately. Redo at four `-c` values (262144, 245760, 221184, 196608)
all hit the same wall — swap growth at depth 81958 — whenever the
window was large enough to reach it. This ceiling does not move with a
bigger `-c`; it is the real per-slot limit. See `results.md`,
`gemma12-gguf-2slot redo`.

`gemma12-gguf-1slot-131072`: clean depth 114718, hit the `-c` boundary
at 131072 (HTTP 400, not OOM) at the top.

Draft kit, not started as a scored run. Pre-block prep landed
2026-09-07: wired 24000 ceilings for Qwen3.6 GGUF q8_0 and f16,
found while debugging a `local-llm-eval-tools` compaction issue on
this machine. See `results.md`, "Pre-block prep" section, for the
numbers, the two open questions (a false-positive compaction stop at
depth 32818, and swap growth under wired 25000 with no recovery gap
between sweeps), and links to the full tool-side evidence on
`local-llm-eval-tools`'s `creep-ab-verdict` and
`creep-configurable-thresholds` branches.

Follow-up landed same day: two clean single-sweep creeps at wired
25000, fresh server each time (`-c 98304` q8_0, `-c 40960` f16), both
zero swap growth and matching run11's original numbers. The swap
growth from the pre-block prep section only ever showed up under
several sweeps stacked back to back with no recovery gap — a pattern
a normal scoring block does not hit. See `results.md`, "Follow-up",
before reading the earlier section's working conclusion; that section
leaned toward 24000, this one weakens that case.

Handing over: the coordinator sets `AGENT.md`'s wired-limit line
(24000 or 25000) after reading both `results.md` sections in full,
then the run proper starts.
