# Goal 1 — backend failure deep-dive

Status: started. This file collects diagnoses with their evidence.


## Kernel panic, 2026-09-03 — IOGPUFamily, not an OOM

The machine panicked and rebooted during goal-3 setup.

    panic(cpu 3 caller 0xfffffe002a410f78):
    "completeMemory() prepare count underflow" @IOGPUMemory.cpp:492
    Panicked task 0xfffffe33c567c7a0: 49094 pages, 40 threads: pid 72957: node
    Kernel Extensions in backtrace:
      com.apple.iokit.IOGPUFamily(104.6.3)

Darwin 24.6.0, build 24G720, M1 Max.

**Memory was not exhausted.** The panic log's own accounting says so:

    Compressor Info: 3% of compressed pages limit (OK) and 8% of
    segments limit (OK) with 3 swapfiles and OK swap space

So this is not the OOM story. It is a reference-counting fault inside
Apple's GPU memory manager — `completeMemory()` decremented a prepare
count that was already zero. A userspace process cannot legitimately
cause that; it is a kernel bug reachable from ordinary GPU work.

The panicking task is `node`, which on this machine means either pi or
LM Studio's server. Both were in play: LM Studio had been loading and
unloading `google/gemma-4-12b` repeatedly while pi ran short probes
against it.

### Why this matters to the measurements

Some failures recorded as OOM or as `harness_crash` may be this. A
kernel panic takes the whole machine, so a run that ends with the Mac
rebooting leaves no server log, no session log, and no result row — the
same signature as a silent death. `benchmarks/bench7/state.md` H1 blamed
unrecovered memory for the dagger sweep, and the evidence for that is
good, but from here on a lost run should be checked against
`/Library/Logs/DiagnosticReports/*.panic` before it is called an OOM.

### What to check after any lost run

    ls -t /Library/Logs/DiagnosticReports/*.panic | head
    log show --last 30m --predicate 'eventMessage CONTAINS "IOGPU"' | tail -40

An empty panic directory means the machine did not crash. This machine
had none before today.

### Suspected trigger, not proven

Repeated load and unload of a model in LM Studio, with a client
connecting between cycles. The sequence before the panic was: load
gemma, start the server, run short pi probes, unload, quit the app,
reload. That is a lot of GPU allocator churn in a short window, which is
the code path the faulting function belongs to.

Not reproduced on purpose, and reproducing it deliberately costs a
reboot each attempt. The cheap mitigation is the one already in the
checklist: load a model once per session, and quit the LM Studio app
rather than cycling it.


## Goal 1 item 4 — the MTP drafter is not broken by the build

The runbook describes the llama.cpp MTP drafter as broken: drafter
allocation fails, `/health` stays green, every later request 500s. It
asks whether the brew build predates llama.cpp PRs 23485 and 20817.

**It works.** Measured 2026-09-03 on the same brew build, using the
vetted command from `docs/setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md`
with only the context lowered from 262144 to 8192:

    llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
      --alias gemma-4-12b-it --no-mmproj \
      --spec-type draft-mtp --spec-draft-n-max 4 --parallel 1 \
      -ngl 999 -fa on -c 8192 \
      --cache-type-k q8_0 --cache-type-v q8_0 \
      --jinja --port 8081

Server log during a live agent session:

    slot print_timing: draft acceptance = 0.51471
      (35 accepted / 68 generated), mean len = 3.06

The drafter allocated, and speculative decoding is accepting drafts at
51%. No 500s, no failed allocation.

### What changed, and what it means

There is only one machine — every local measurement in this project runs
on this Mac — so nothing here compares hardware. What differs from the
failing observation is the machine's STATE and the config:
the context is 8192 instead of 262144, the Mac had just rebooted and was
quiet, and no other model was resident.

So the failure is **conditional, not a build defect**. The build is
unchanged. That reframes item 4: the question is no longer "is the brew
build too old for PRs 23485 and 20817", it is "at what context and what
memory pressure does the drafter allocation start failing".

That is also consistent with bench7 H2, which found that `-ngl 999`
disables llama.cpp's automatic memory fitting. With fitting disabled the
loader proceeds into the MTP draft-context init unconditionally and hits
a real Metal allocation failure. At 8192 there is room, so it succeeds;
at 262144 there is not, and the same code path fails hard because the
safety net was switched off by the very flag the vetted config uses.

### What would settle it

A context ramp on a quiet machine with the drafter enabled: 8K, 32K,
64K, 128K, 262K, recording at each step whether the drafter allocates
and what free and wired memory are. The failure point is the answer. The
same ramp with `-ngl` removed would show whether automatic fitting
degrades gracefully instead of failing, which is the fix if it does.

Not run here. It is a context ramp, which is a measurement that belongs
in a benchmark kit rather than a research aside.
