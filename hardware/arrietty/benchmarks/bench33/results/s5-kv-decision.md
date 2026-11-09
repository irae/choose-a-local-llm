# S5-nano KV decision

Coordinator decision, 2026-11-08, from the pushed `s5-kv-feedback`
evidence at `4d79737`.

Use q8_0 KV for the pinned S5-nano Q8_0 file on official llama.cpp
v0.9.0, b12110, without MTP. Both cache types served at `-c 34816`.
Their 32K decode readings are both 66.02 tok/s. The curves differ by
less than 10 percent. q8_0 uses less GPU memory. The fixed smoke is
LEVEL: both types passed 3 of 4 problems with no empty answer. This
is a cache choice, not a full quality score.

Accept the timed speed cells. The direct machine-start sample had
zero swap used. The first f16 cell began with 13,288 KiB used in
zram. Every before and after sample of the measured cells had that
same value. Thus the recorded increase predates the timed cells;
the cells show no observed swap growth. Keep the increase as a
deviation. Do not describe setup as swap-free. This decision accepts
the throughput samples, not a measured maximum allocation ceiling.

The depth block must measure its own ceiling and clean depth. Its
newest result sets the later serving context and harness window.
