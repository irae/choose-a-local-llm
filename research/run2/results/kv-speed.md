# P3 — KV cache type against the published speed

Run 2, session 1, 2026-09-04, 07:57Z to 08:18Z. Script: `kv-speed.sh`.
Same vetted Gemma-12B llama-server command, the published page's own two
prompts, 256 tokens, temperature 0. Only the KV cache type changes.

## Result

| KV | Context | py tok/s | js tok/s | prompt tok/s | draft acceptance | wired |
| --- | --- | --- | --- | --- | --- | --- |
| q8_0 | 32768 | 27.45 | 28.42 | 62-63 | 0.580 / 0.608 | 10395 MB |
| q8_0 | 262144 | 27.47 | 28.47 | 62-64 | 0.580 / 0.608 | 13645 MB |
| f16 | 32768 | 32.10 | 32.96 | 67-68 | 0.586 / 0.608 | 10820 MB |
| f16 | 262144 | 31.95 | 32.84 | 68-69 | 0.586 / 0.608 | 15766 MB |

**f16 is worth about 4.6 tokens per second over q8_0**, on both prompts
and at both contexts. The published page estimates "+5.5 py tok/s" for
f16. That estimate is confirmed.

f16 costs memory: +425 MB at 32K, and **+2121 MB at 262K**. At the top
context f16 needs 15.8 GB wired against q8_0's 13.6 GB. The KV policy
that chose q8_0 buys 2.1 GB of headroom for 4.6 tok/s, which still looks
like the right trade on a 32 GB machine.

## The published 45.0 is not explained by the KV type

The page publishes **45.0 py / 31.3 js**. Set the best arm here beside
it:

| | published | measured now (f16, 262144) |
| --- | --- | --- |
| py | 45.0 | 31.95 |
| js | 31.3 | **32.84** |

**The js number matches, and slightly exceeds it. Only py is short.**

That reframes the gap completely. If the build, the wired limit, or the
machine were slower, both prompts would be slower. They are not. Our js
is faster than published while our py is 29 percent slower.

So the difference is not general speed. It is specific to the py prompt.

**And the build is not a candidate at all.** `/props` on the running
server reports `build_info: b10621-c1d0e7a00`. The published page cites
"build 10621, commit c1d0e7a00". They are the same build. Homebrew
`llama.cpp` 0.3.0 IS build 10621. That removes one of the three
candidate explanations outright and leaves the wired limit and the
drafter.

## What it most likely is, stated as a hypothesis

Draft acceptance. This configuration's speed comes from the MTP drafter,
and the page's own numbers show the drafter helping the two prompts very
unequally: "+102% / +41%" for py and js over a 22.3 tok/s no-MTP
baseline.

Our acceptance is nearly equal on the two prompts: **0.580 on py, 0.608
on js**. The published run must have had far higher acceptance on py to
reach 45.0 from 22.3, because 45.0 is 2.02 times the baseline while our
py reaches only 1.44 times it.

That is consistent and it is not proved. Two things would settle it, and
neither was run here:

1. Measure this build with `--spec-type none` and compare against the
   published 22.3 no-MTP baseline. If the baseline also matches, the
   whole difference is drafter acceptance.
2. Record acceptance per prompt in any future speed row. The published
   table does not carry it, which is why this took a re-measurement to
   notice.

## Proposal, replacing the earlier one

The earlier note in `context-ramp.md` suggested a general re-probe
before the 45.0 figure is quoted again. Narrow it:

- The **js** figure is sound and reproduces.
- The **py** figure of 45.0 does not reproduce on this build, and the
  cause is most likely drafter acceptance rather than anything about the
  machine.
- **Any speed row using MTP should record draft acceptance beside the
  tokens per second.** A speculative-decoding number without its
  acceptance rate cannot be compared against a later run, and this is
  exactly the confusion that produced it.

Evidence: `~/.local/share/choose-a-local-llm/evidence/run2-kv-speed/`.
