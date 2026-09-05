# Config changes proposed as diffs — not applied

Run 2, session 1, 2026-09-04. Every change below alters a published
measurement or the owner's harness config, so none of them is applied.
They are written here for the owner to accept, change, or refuse.

## P1 — Qwen3.8 window arithmetic (T2.2, section E)

**Where:** `~/.pi/agent/models.json`, provider `mlx`, entry
`mlx-community/Qwen3.8-27B-4bit`.

**Now:**

```json
"contextWindow": 26624,
"maxTokens": 16384,
```

**The problem, measured in run 7.** Three turns stopped on `length`
after one output token, with about 20318 prompt tokens and a 16384
output budget. 20318 + 16384 = 36702 against a declared window of
26624. The two numbers cannot both be honoured once a prompt passes
10240 tokens, which every agent run passes within a few turns.

**Proposed:**

```json
"contextWindow": 26624,
"maxTokens": 8192,
```

**Why 8192.** It is the largest power-of-two budget that still fits
beside a prompt of 18432 tokens, which is where run 7's failures
happened. The rule it encodes: **`maxTokens` must fit under
`contextWindow` alongside the largest prompt the run will reach, not
alongside an empty one.**

**What it costs.** A turn that genuinely needs more than 8192 output
tokens will now stop at 8192 instead of at 1. Stopping late is a
truthful measurement; stopping at 1 is not.

**What it does not fix.** The window itself. 26624 was chosen below a
ceiling of about 29K measured at `iogpu.wired_limit_mb=25000`, and the
machine now runs at 24000. The re-probe that would justify a different
number needs the GPU and is still queued in this run. If the re-probe
raises the ceiling, `contextWindow` can rise and `maxTokens` with it,
keeping the same rule.

**Note for the runner.** `mlx_lm.server` has no window of its own
(run 1, `backend-diagnosis.md`). Both numbers are pi's, so this diff
changes when the harness compacts and nothing about the server.

## P2 — Bonsai thinking level for Mendel runs (T3.1, section B)

**Where:** the run command, not a config file.

Both Bonsai entries in `~/.pi/agent/models.json` map thinking levels
like this:

```json
"thinkingLevelMap": {
  "off": "off", "minimal": null, "low": null, "medium": null,
  "high": "high", "xhigh": null, "max": null
}
```

`low` maps to `null`. The Mendel runs were scheduled at `low`, so the
level the run asked for does not exist on this model. Only `off` and
`high` are reachable.

The owner decided on 2026-09-03 to use thinking OFF. That is also the
published best row: `Ternary-Bonsai-27B, MLX, bounded cache, thinking
off` scores **0.927 base / 0.902 plus**, above the thinking-on MLX row
(0.915 / 0.884) and above the fork's thinking-on row (0.927 / 0.890).

**Proposed:** run Bonsai Mendel arms as

```
./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi guided off
```

No config edit is needed for this: `off` already maps to `off`. What IS
needed is that the run is labelled `off`, so it never again records a
level the stack cannot reach.

**Second half, not settled.** Section B also asks for q8_0 KV on the
prism fork in place of the calibrated q4. The published fork command
is:

```
--cache-type-k q4_0 --cache-type-v q4_0 \
--kv-mean-center /tmp/Ternary-Bonsai-27B-kv-bias.gguf
```

This is not naive q4: the `--kv-mean-center` bias file is a calibration
built for exactly this quantization. Swapping the KV type to q8_0 while
keeping a bias file calibrated for q4 would test neither config. The
honest arm is q8_0 KV **without** the bias file, at reduced context if
memory demands, and it must be compared against the fork's own q4 plus
bias row rather than against the MLX row. That arm is GPU work and is
not proposed as a diff, because there is nothing to change until it is
measured.

## P3 — llama.cpp Gemma-12B speed re-probe (from T2.1)

Not a config change. `docs/setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md`
publishes 45.0 py tokens per second for the recommended configuration.
The context ramp measured 27.3 tokens per second at every context from
8K to 262K on the current homebrew build with q8_0 KV at
`iogpu.wired_limit_mb=24000`. Detail and the three candidate
explanations are in `context-ramp.md`. The page already says a q8
re-probe is pending; this is evidence that it matters more than the
+5.5 tok/s the page expects.

## P4 — a liveness watcher that probes a real completion (section E)

**Where:** `results/liveness-watch.sh` in this run folder. **Not**
promoted to `benchmarks/` or `tools/`, because a new shared tool is the
owner's call, not a research run's.

Section E asks for a watchdog that probes a REAL completion rather than
`/health`, because `mlx_lm.server`'s generation thread can die while the
process lives and `/health` keeps answering 200.

The design question a timer-based probe cannot answer: these servers run
one slot, so probing on a schedule competes with the run. This one
probes **on suspicion** instead.

1. Watch the run's own output file for growth.
2. Only when growth has stopped for `STALL_SECONDS`, send one real
   completion with a long timeout.
3. A completion that returns means the server is alive and the model is
   merely thinking. One that does not return means the server is dead,
   whatever `/health` says. Exit 42 in that case.

Smoke-tested against the live T1.1 server: it reported
`STALL 30s: health=ok probe=alive 13s` and correctly declined to call it
a failure. The probe queued behind the running generation and cost 13
seconds and one token, which is the price of the design and is small.

If the owner wants it, it belongs in `benchmarks/` beside `mem-watch.sh`
and needs a line in the `AGENTS.md` index in the same commit.
