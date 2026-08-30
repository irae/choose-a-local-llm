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
