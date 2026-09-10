# A/B: llama-benchy against the creep for decode speed at depth

Status: draft 2026-09-10. Origin: the drafter table on the Qwen3.8 ISTA
build, where the creep read 10.30 tok/s at 98K with the drafter at
n-max 3 and a real-prompt cell read 7.89. Needs hardware: yes, about
two hours on the Mac, one build, two serving configs. **The A side is
already measured**: the no-drafter creep of 2026-09-09
(`benchmarks/bench13/results/creep-ista-nodrafter.tsv`) and the n-max 3
creep of 2026-09-08 (`run3/results/creep-qwen38-ista-iq3s-mtp.tsv`),
with their server logs. Only the benchy side runs.

## The problem this item answers

The creep fills context with one three-line function repeated with an
incrementing number, and each step generates 64 tokens of the same
template at temperature 0. That is the lowest-entropy text possible.
With a drafter on, the server log shows 100 percent draft acceptance
on every step from 25K down, so every drafter tok/s the creep reports
past 16K is a best case no real workload gives. The no-drafter rows
are unaffected, because decode cost at depth depends on the KV length
and not on the content: the creep's 9.69 and the real-prompt cell's
9.50 at 98K agree within 2 percent.

The creep keeps its ceiling job. The ceiling is content-independent:
the largest `-c` that serves, the clean depth, the swap and compression
stops, the dead-server exit. What it cannot give is a drafter's speed.

The community measures speed at depth with real text. `llama-bench`
fills with random token ids and cannot measure a drafter at all.
`llama-benchy` fills with a Project Gutenberg book, and says why:
random tokens do not measure speculative decoding or MTP. llama.cpp's
own speculative-decoding doc points to SPEED-Bench, which reports
tok/s and acceptance side by side per prompt category and per entropy
split, at temperature 0 by default. The literature puts acceptance on
the task domain first and on temperature second: one paper reads 0.76
to 0.80 at temperature 0 against 0.51 to 0.57 at temperature 1 on the
same prompts.

The decision: adopt `llama-benchy` for the speed comparison between no
drafter and each `n-max`, and keep the creep for the ceiling. This item
checks that its numbers are the ones the agent gets, before any row
reads from it.

## What llama-benchy has and lacks

Has: decode tok/s at a list of depths from real text, a warmup run,
repeats with a standard deviation, prefix reuse between depths, any
OpenAI-compatible server, markdown, JSON and CSV output, and
community-comparable numbers.

Lacks: memory sampling, stop conditions, dead-server detection from
the server log, an acceptance column, and a pause between depths. It
downloads a tokenizer from Hugging Face unless given a local path.
Sampling goes through `--extra-body`.

Two of those are recoverable inside the tool: `--post-run-cmd` runs a
shell command after each test, so it can sleep 60 s and append one
`vm_stat` line to a file; acceptance is in llama-server's log after
every request, which the runner already reads.

## Mac procedure

Build: `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, rev `d562806`,
f16 KV, `--no-mmproj`, wired 25000. Two serving configs:

| arm | drafter flags | `-c` |
| --- | --- | --- |
| `none` | no `--spec-type`, no `--spec-draft-n-max` | 163840 |
| `n3` | `--spec-type draft-mtp --spec-draft-n-max 3` | 131072 |

Install: `pipx install llama-benchy`, or into the run venv at
`~/.venvs/local-llm-bench`. Record the version. The tokenizer is
`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF`'s base model's; if the download
is blocked by the per-process firewall, pass a local path with
`--tokenizer`. Say in `state.md` which path was used.

Corpus: pass `--book-url` a text the model cannot have seen. The
default Sherlock Holmes is in every training set. A recent
public-domain text or one of this project's own long documents is
fine; record the URL and its token count.

One run per arm, four depths, 256-token generations, three repeats
after one warmup, at the serving sampling:

```bash
llama-benchy --base-url http://127.0.0.1:8081/v1 --model qwen3.8-27b-ista \
  --pp 512 --tg 256 --depth 4096 49152 98304 147456 \
  --runs 3 --warmup-runs 1 \
  --extra-body '{"temperature":1.0,"top_p":0.95}' \
  --post-run-cmd 'sleep 60; vm_stat | head -12 >> results/benchy-<arm>-vm.log' \
  --format md --save-result results/benchy-<arm>.md
```

The `n3` arm stops at depth 98304, since its window ends at 131072 and
the 147456 depth does not fit. Keep the server log for both arms; the
acceptance line after every request goes into the results beside its
tok/s.

Then one more run per arm at temperature 0, same depths, so the
temperature effect on acceptance is a measured number and not a
paper's.

## Pass criteria

Read the `none` arm against the creep of 2026-09-09 (14.14 at 4K, 11.51
at 49K, 9.69 at 98K, 8.30 at 147K). Pass if every cell lands within 5
percent: that shows the tool measures what the creep measures where
content does not matter.

Read the `n3` arm at 98K against the two numbers this item exists for:
the creep's 10.30 and the real-prompt cell's 7.89. Pass if it lands
near 7.89, at acceptance in the 60 to 80 percent range the agent runs
see. A reading near 10.30 with acceptance above 95 percent means the
corpus is memorised or the tail prompt is a template, and the item
fails on the corpus, not on the tool.

Record acceptance for every cell. A row without it is not a drafter
measurement.

## What the result changes

Pass: `docs/methodology/context-creep.md` gains the rule that a
drafter's speed at depth comes from `llama-benchy` at the serving
sampling, and the creep's tok/s column on a drafter row is a ceiling
test only. The drafter tables on the model pages re-read from the new
numbers. The run 12 sweep that kept n-max 3 on the two 3-bit builds
compared a creep row against real-prompt cells and is re-read too.

Fail on the tool: the creep's step prompt gets a real tail task at the
serving sampling with 256 tokens and an acceptance column, which is
the same fix built by hand.

## Cost against the creep

A creep to 164K takes about 48 minutes: each step prefills only the
new block, generates 64 tokens and pauses 60 s. A `llama-benchy` run
over four depths costs one prefill of the deepest depth, about 30
minutes at 90 tok/s for 147K, plus four generations of 256 tokens per
depth at 8 to 14 tok/s, about 20 minutes, plus the pauses. About an
hour per arm and per temperature. The creeps are already on disk, so
the A/B is two benchy runs at the serving sampling, about two hours,
plus the optional temperature-0 pair. After adoption a drafter
question on a new build costs one benchy run per `n-max` cell at two
or three depths, about 40 minutes each, against a creep that reads
the wrong number in 48.

## Beyond the A/B: benchy as the adapter, the creep as the monitor

If the A/B passes, the two tools can become one. `llama-benchy` gives
the ladder when it is passed the whole depth list, and `--emit-progress`
streams one JSON event per completed test, so a monitor beside it can
read each rung's tok/s as it lands. Everything the creep owns that
benchy lacks is monitor work: the 60 s pause, the `vm_stat` sample per
rung, the floor, swap-growth and compression stops, the server-log
liveness read, the dead-server exit 42. That is the shape
`CONVENTIONS.md` already asks for, one module owns the method and a
thin adapter owns the backend: the method module keeps the stop rules
and the memory record, and benchy becomes the adapter that fills the
context and reads the speed. The cleanest cut is rung by rung: the
monitor calls benchy with one `--depth` at a time, reads the result,
samples memory, applies the stop rules, pauses, and goes on; prefix
reuse keeps each rung cheap.

What is lost and has to be decided: the creep's round-robin
`N_CONTEXTS`, which the two-slot rows use, has no benchy equivalent
(`--concurrency` runs slots in parallel, which is a different
measurement), and benchy is a third-party moving target that needs a
pinned version. Neither blocks the A/B; both block a replacement.
