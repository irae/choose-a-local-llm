# Memory ceiling — how much context the machine can allocate

Find context maxima by probing, not by spec sheet. Common rules and the
run loop apply ([common rules](./common-rules.md),
[checklist](./checklist.md)).

## Steps

1. Raise the allocated context (`-c`) in fixed steps (we use 8K).
2. At each step: load, validate with a real prompt, record RSS.
3. Stop at the GPU OOM (`kIOGPUCommandBufferCallbackErrorOutOfMemory`
   on Metal). A config that loads but decodes degraded counts as
   failed.
4. Record on every surface, with the wired limit it was measured under.
5. Record the allocation RATE too, and never compare a ceiling measured
   at one rate with a ceiling measured at another.

## Rate changes the ceiling, so a benchmark OOMs early

A ceiling is not a property of the machine alone. It also depends on
how fast the memory is asked for.

macOS answers a large allocation by compressing and evicting idle
pages, and that work takes time. Ask fast and the system cannot keep
up, so the allocation fails while memory it could have freed is still
in use. Ask slowly and the same machine yields more.

This matters because our benchmarks and our real workload sit at
opposite ends of that scale. A sweep that raises `-c` and reloads in a
tight loop is the fast case. A coding agent is the slow case: it stops
constantly for tool calls, test runs, web requests and model thinking,
and every one of those gaps is time the system uses to catch up.

So **a benchmark OOM is pessimistic**. The config that failed a sweep
may serve a real agent session at the same size. Do not turn a swept
ceiling into a published maximum without saying it was measured fast.

When a ceiling decides something the owner will rely on, measure it at
both rates and quote both. `tools/mem-probe.py --pause` exists for
this: `--pause 0` is the fast case, a pause of a second or more
approximates the gaps in agent work.

## Know which limit actually gates the OOM

Well under the physical RAM, `iogpu.wired_limit_mb` gates cleanly: the process's `IOAccelerator (graphics)` resident memory
(per-process view: `vmmap --summary <pid>`) hits the sysctl value
exactly and the process gets the Metal OOM while the system stays
healthy. That per-process view is not universal: `mlx_lm.server` holding
8.5 GB read 1.7 MB in `IOAccelerator`, so for MLX servers read `Pages
wired down` in `vm_stat` instead
(`research/run1/results/backend-diagnosis.md`).
Near the physical RAM, it binds first: free RAM runs to near zero
before the sysctl matters, the crash point stops responding to sysctl
changes, and the machine locks up and shows visual glitches. Ceilings
measured in that regime are the machine's true maxima but cost system
usability. Where that line sits is a value in the machine file.

Budget model for MLX (measured on one 35B MoE 4-bit config; the KV cost
per token is model-specific): weights + a ~1-2 GB transient prefill
spike + ~115 KiB per token of KV.

LM Studio ignores `-c` for some MLX models and computes the window
itself from the wired limit — for those configs there is no allocation
probe to run; use the compression-onset criterion from
[context creep](./context-creep.md) instead.


## Why the cold-start sequence exists

The [checklist](./checklist.md) step 3 gives the sequence. This is what
it is for.

**There is no idle baseline.** The same idle machine, with the same
applications not running, has read free memory values twelve gigabytes
apart (the setup page holds the readings). Free memory moves by more
than a gigabyte on its own while scheduled work runs, and by far more
after something has applied pressure. A gate that compares against a remembered number is comparing
against noise.

So the sequence does not chase a clean machine. It aims to put the
machine in the SAME state before every run. Reproducibility, not
accuracy. Two runs prepared this way can be compared with each other,
which is what a benchmark needs.

**Why the reboot, and when.** A disabled login item that is already
running keeps running, so disabling without rebooting changes nothing.
A reboot also clears swap, and swap growth during a speed or ceiling
run invalidates the number. And it is the only recovery from a panic
or a lockup. When none of those holds, the reboot buys nothing, so the
checklist makes it conditional.

**Why the model is the balloon.** Pressure has to come from somewhere,
and it may as well come from the thing being measured. A synthetic
balloon is the wrong shape: it allocates one flat block, while a server
allocates weights once and then grows a KV cache. Loading the real model
and walking its context up does the same five jobs at once — applies the
pressure, warms the model, proves the config instead of assuming it,
yields the ceiling for that exact config, and fails early if it is going
to fail at all.

The synthetic probe (`tools/mem-probe.py`) stays for investigating the
machine's behaviour. It is not part of run preparation.

**Why slowly.** Rate changes the ceiling; see the rate rule above. A
fast walk drives the machine into swap and reports a number no real
session would meet.

**Why swap is judged by the delta.** macOS does not refuse an
impossible request. It compresses, then swaps, then keeps going. A run
that swaps can complete and report throughput that measures the swap
file. A failed allocation is easy to spot; a slow one is not.

Leftover swap from an earlier run is not the problem. Those pages
belong to processes that already released them: they cost disk, not
memory, and nothing reclaims them into the next run. Requiring zero
would mean rebooting for no gain. What matters is growth DURING the
run, so record the starting value and watch for an increase.

The consequence of growth depends on what is being measured. A
throughput or ceiling number is invalid, because it timed the swap
file, and the point where swap starts growing is the real ceiling. A
judged score — Mendel, polyglot, EvalPlus — survives, because the
answer is graded rather than timed; record it as a deviation.

**Why the balloon is optional.** Above a threshold of free memory the
machine has already yielded and pressure buys nothing. The threshold is
a value in the machine file. Probe first, balloon only below it.

**Why wired is the counter to read.** Wired pages are never compressed
and never swapped. Everything else can mislead: free and active move for
unrelated reasons, and the compressor can inflate an allocation total
until it is fiction. An early version of the probe filled blocks with a
repeated value and "allocated" more than the machine has, because the
compressor squeezed the blocks to nothing. Wired never lied.

**What the sequence costs.** A reboot only when a condition calls for
one, and a few minutes of slow loading per config when the balloon is
needed at all. The background items stay disabled until
`tools/mac-services.sh restore` runs, so the owner gets their machine
back when the session ends.

Full measurements behind this: `research/run1/results/memory-gate.md`.
