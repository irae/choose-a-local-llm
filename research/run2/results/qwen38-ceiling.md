# T2.2b — the Qwen3.8-27B context ceiling at wired 24000

Run 2, session 1, 2026-09-04, 07:47Z to 07:56Z. Script:
`qwen38-ceiling.sh`, driving the shared `tools/sweeps/mlx_sweep.py`.
`mlx_lm.server` 0.31.3, `mlx-community/Qwen3.8-27B-4bit`,
`--prompt-cache-size 2`, `iogpu.wired_limit_mb=24000`, machine quiet,
zero swap at start.

## Result

| Depth reached | Decode | Step time |
| --- | --- | --- |
| 24667 tokens | 14.42 tok/s | 216 s |
| 26708 tokens | 15.39 tok/s | 23 s |
| next step, 28672 | **server generation thread died** | — |

**The ceiling at wired 24000 lies between 26708 and 28672 tokens.**

The published entry describes a ceiling of about 29K, measured at
`iogpu.wired_limit_mb=25000`. Lowering the wired limit by 1000 MB moved
the ceiling below 28672. That is consistent, and it settles the question
run 1 left open.

## What it means for the declared window

`contextWindow` is **26624**. The last depth that worked is 26708. So
the declared window sits about **84 tokens** below the highest measured
success — not the comfortable margin the entry's own description
implies.

It is not wrong. It is thin. Two readings, and the owner picks:

- **Leave it.** 26624 is below a real measured ceiling, and pi compacts
  before reaching it. The run 7 failures were the `maxTokens` arithmetic
  (proposal P1), not the window.
- **Lower it** to about 24576, the next step down that is comfortably
  inside the last two measured successes. It costs 2048 tokens of
  context and buys margin against a failure that kills the server
  outright.

Either way, proposal P1 in `config-proposals.md` stands unchanged:
`maxTokens` 16384 cannot coexist with this window once a prompt passes
10240 tokens, and that is what actually broke run 7.

## The failure mode is the upstream dead-thread bug, reproduced

The step past 26708 did not return an error to the client. The server's
**generation thread died and the process kept running**:

```
File ".../mlx_lm/server.py", line 853, in _generate
  prompt_responses, gen_responses = batch_generator.next()
...
File ".../mlx_lm/generate.py", line 1161, in prompt
  mx.eval([c.state for c in self.prompt_cache])
RuntimeError: [METAL] Command buffer execution failed: Insufficient
Memory (00000008:kIOGPUCommandBufferCallbackErrorOutOfMemory)
```

That is section E's bug, live on our stack: upstream issues 1505, 1390
and 854, whose fixing PRs are still unmerged in 0.31.3. The OOM happens
inside `mx.eval` on the prompt cache, so the thread that dies is the one
that generates, and nothing tells the client.

**What caught it was the log, not `/health`.** The shared sweep tool's
watchdog greps the server log for `Insufficient Memory`, saw it, and
exited 42. A health check would have reported a healthy server.

This is direct support for the watchdog design in
`config-proposals.md` P4: `liveness-watch.sh` probes a REAL completion
after output stalls, which is the only client-side signal that survives
this failure. Two independent detectors now exist — the log grep, which
needs the server log, and the completion probe, which does not.

## Machine state after

Wired fell from the run's peak to 1630 MB within seconds of the kill and
settled at about 1599 MB. Zero swap throughout. Evidence in
`~/.local/share/choose-a-local-llm/evidence/run2-qwen38-ceiling/`.
