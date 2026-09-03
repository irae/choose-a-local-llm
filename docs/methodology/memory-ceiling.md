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
4. Speculative decoding: sweep the draft depth per model AND per mode —
   the optimum shifts with output style (thinking on/off) and with
   depth.
5. Record on every surface, with the wired limit it was measured under.
6. Record the allocation RATE too, and never compare a ceiling measured
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

Below ~24000 MB on a 32 GB machine, `iogpu.wired_limit_mb` gates
cleanly: the process's `IOAccelerator (graphics)` resident memory
(per-process view: `vmmap --summary <pid>`) hits the sysctl value
exactly and the process gets the Metal OOM while the system stays
healthy. At ~24000 MB and above, physical RAM binds first: free RAM
runs to near zero before the sysctl matters, the crash point stops
responding to sysctl changes, and the machine locks up and shows visual
glitches. Ceilings measured in that regime are the machine's true
maxima but cost system usability.

Budget model for MLX (Qwen3.6-35B measured): weights + a ~1-2 GB
transient prefill spike + ~115 KiB per token of KV.

LM Studio ignores `-c` for some MLX models and computes the window
itself from the wired limit — for those configs there is no allocation
probe to run; use the compression-onset criterion from
[context creep](./context-creep.md) instead.


## Why the cold-start sequence exists

The [checklist](./checklist.md) step 4 gives the sequence. This is what
it is for.

**There is no idle baseline on this machine.** Measured idle, with the
same applications not running, it has read 12415 MB free and 25219 MB
free. Free memory moves by more than a gigabyte on its own while
scheduled work runs, and it moves by twelve after something has applied
pressure. A gate that compares against a remembered number is comparing
against noise.

So the sequence does not chase a clean machine. It aims to put the
machine in the SAME state before every run. Reproducibility, not
accuracy. Two runs prepared this way can be compared with each other,
which is what a benchmark needs.

**Why the reboot.** A disabled login item that is already running keeps
running, so disabling without rebooting changes nothing. The reboot also
clears swap, and swap left over from a previous run silently changes the
next one.

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

**Why the balloon is optional.** Above 25 GB free the machine has
already yielded and pressure buys nothing. Probe first, balloon only
below that.

**Why wired is the counter to read.** Wired pages are never compressed
and never swapped. Everything else can mislead: free and active move for
unrelated reasons, and the compressor can inflate an allocation total
until it is fiction. An early version of the probe filled blocks with a
repeated value and "allocated" 35840 MB on a 32 GB machine, because the
compressor squeezed the blocks to nothing. Wired never lied.

**What the sequence costs.** One reboot per session, and a few minutes
of slow loading per config when the balloon is needed at all. Reboot
once per session, never once per model; when the machine is doing
nothing but benchmarks, one reboot can cover several days. The background items stay disabled until `tools/mac-quiet.sh on`
runs, so the owner gets their machine back when the session ends.

Full measurements behind this: `research/run1/results/memory-gate.md`.
