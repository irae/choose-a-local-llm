# T1.1 — the Gemma-12B replay on llama-server

Run 2, session 1. Arm 1 ran 2026-09-04 02:43Z to 05:13Z on the freshly
rebooted machine, `iogpu.wired_limit_mb=24000`, zero swap throughout.

The question, from AGENT.md section D alternative 1: **does the
tool-call loop appear on a non-MLX backend?** Everything else is held
fixed — the same failing `google-gemma-4-12b-low-guided` task, the same
archived 3935-character prompt, the same base commit
`benchmark-guided-base`, the same runner (`run-pi-rpc.mjs`), the same
frozen `agents-global.md`, thinking level `low`, and a declared context
of 158464 so pi compacts where the LM Studio arm compacted.

What changes: the backend. `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL` on
llama-server with the MTP drafter, q8_0 KV, served at 262144.

## Result

Both columns counted by the same instrument,
`results/count-events.py`. On run 1's archived session it reproduces the
numbers run 1 published independently, so the counter is calibrated.

| | LM Studio MLX (run 1 replay) | llama-server (this arm) |
| --- | --- | --- |
| tool calls | 71 | 75 |
| distinct calls | 30 | **60** |
| longest identical run | 37 | **2** |
| most repeated call | `bash {"command": 4}`, 40 times | `pnpm run unit`, 4 times |
| model nudges | at least one, and it drew a flood | **0** |
| respawns | — | 0 |
| compactions | — | 0 |
| commits produced | 0 | **3** |
| end reason | — | `wall_clock` |
| prompt-cache share | — | 97.7% |

**The loop does not appear on llama-server.** At almost the same number
of calls, this arm produced twice the distinct calls and never repeated
one more than twice in a row. The LM Studio arm spent 37 consecutive
calls re-emitting `bash {"command": 4}`, an integer where a string
belongs.

## What else the arm shows

**It never stopped.** Zero model nudges, zero tooling nudges, zero
respawns, zero compactions in 150 minutes. One retry, on a transient
`Connection error.` at 03:17Z. The run ended only because it hit its own
wall clock. The LM Studio arm's one preserved flood, by contrast, came
directly after a model nudge (`results/flood-shape.md`).

**It did the work.** Three commits, each removing one dependency —
`uuid`, `xtend`, `urlsafe-base64` — with a clean working tree at the
end. The original failing run made 130 calls and committed nothing.

**One behaviour worth naming, and it is not a backend difference.** The
model never ticked a checkbox in `TASKS.md`: 0 of 8, after committing
three of the eight dependencies. The runner's model nudge fires when
`TASKS.md` still has unchecked items. So a model that works correctly
but does not tick boxes will be told "You are not done" indefinitely.
That is a harness-model interaction, it applies to both backends, and it
is the exact message the LM Studio flood followed.

## What this does and does not settle

**Settles:** the failure is not intrinsic to Gemma-4-12B as served here.
The same model, the same weights family, the same task and the same
harness produce clean, recovering behaviour on llama-server.

**Does not settle:** which of the two differences between the paths
causes it. The MLX path differs in at least three ways: it is a
different engine, it serves a container whose `chat_template.jinja` is
Google's pre-fix revision, and its handling of OpenAI-shaped tool-call
arguments is unverified (`results/container-audit.md`, findings 1b-1d).

Arm 2 isolates one of those three. It forces this same GGUF, on this
same backend, onto the pre-fix template. If the loop appears there, the
template is sufficient on its own. If it does not, the cause lies in the
engine or the argument handling, and the LM Studio probe in
`flood-shape.md` becomes the next step.

**A caveat on the wall clock.** Both arms were cut off rather than
finished. The LM Studio arm was already looping when it was cut; this
one was still working. An arm that has not looped by 75 calls has not
proved it never will — but the original looped by call 11, and both
prior LM Studio measurements were repeating well before this point.

## Deviation recorded

The arm's own cleanup did not run. The script was edited while bash was
still reading it, which changed the byte offsets under a running
interpreter, and it aborted at end of file after `run_replay` returned.
The server was left up and the evidence unarchived; both were handled by
hand within a minute, and wired memory fell from about 15 GB to 2.3 GB
on the kill. No measurement is affected — the run had already ended and
written its files. **Do not edit a shell script while it is running.**

Evidence: `~/.local/share/choose-a-local-llm/evidence/run2-replay-embedded/`.

---

# Arm 2 — the same GGUF forced onto the pre-fix template

Started 2026-09-04 05:15Z, same 150-minute wall. Everything is held
fixed against arm 1 except one thing: `--chat-template-file` points at
Google's pre-fix revision `657684f` of 2026-06-03, the file every local
`chat_template.jinja` still ships.

Both arms were proved to be running the template intended, from their
own live servers, with `POST /apply-template`
(`container-audit.md`, finding 1e). Both render the tool call correctly,
because llama-server deserializes `function.arguments` first. So arm 2
isolates exactly one variable: **the missing generation prefix after a
tool response.**

## The result: the pre-fix template collapses into repetition

Measured with `measure-collapse.py` on both arms' thinking output.

| | Arm 1, post-fix template | Arm 2, pre-fix template |
| --- | --- | --- |
| thinking lines | 351, 305 distinct | 514, 294 distinct |
| **longest identical consecutive line run** | **1** | **173** |
| most repeated line | ` ```javascript `, 10 times | `Actually, I'll just use \`write\` for this file as well.`, **176 times** |
| time in the collapse | — | 22 minutes and counting, 06:44Z to 07:06Z |

Arm 1 never repeated a single thinking line twice in a row across 150
minutes. Arm 2 repeated one line 173 times in a row.

Same weights, same backend, same build, same task, same prompt, same
harness, same thinking level, same quiet machine, same wired limit. The
chat template is the only difference.

## Why the earlier checks missed it

The tool-call counter reads arm 2 as healthy: 40 calls, 37 distinct,
longest identical run 2. The newline check reads it as clean: no run of
eight newlines, no channel-open token. Both are correct and both are
blind to this shape.

The collapse is inside the thought channel, in well-formed prose, with
no tool call emitted at all. From outside it looks like a model
thinking hard. The only outward sign is that tool calls stop advancing
while the event stream keeps growing — the same signature as a long
tool call, which is why it needed a direct look at the text.

`measure-collapse.py` now detects it, and it should run beside
`flood-check.py` on any Gemma-4 run.

## What this does and does not establish

**Establishes:** the pre-fix chat template is sufficient, on its own, to
produce a repetition collapse in Gemma-4-12B on llama-server. Nothing
about the MLX engine is needed to explain it.

That matters directly, because **every Gemma-4 MLX container on this
machine serves that template** and `AutoTokenizer` resolves to it
(`container-audit.md`, findings 1a-1b). The published Gemma-12B rows
were measured on it.

**Does not establish:** that it is the only cause, or that it explains
the LM Studio tool-call loop specifically. Arm 2's collapse is in the
thinking channel; the LM Studio failure repeated malformed tool calls.
Those are two surfaces of the same family, not the same event. And each
arm is n=1.

**Does not establish** a fix for the published rows either. Replacing
the template changes the configuration those rows were measured on.
That is the owner's decision, written up in `container-audit.md`.
