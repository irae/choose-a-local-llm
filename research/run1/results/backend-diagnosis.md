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
