# A/B: llama-benchy against the creep for decode speed at depth

Status: draft 2026-09-10, scheduled as the only item of research run 4.
Origin: the drafter table on the Qwen3.8 ISTA build, where the creep
read 10.30 tok/s at 98K with the drafter at n-max 3 and a real-prompt
cell read 7.89. Needs hardware: yes, about one hour on the Mac, one
build, two serving configs. **The creep side is already on disk**: the
no-drafter creep of 2026-09-09
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
9.50 at 98K agree within 2 percent. The same artifact sits under every
drafter row on the site: the Qwen3.6 f16 creep ran at 100 percent
acceptance from its third step and the bartowski ladder at 99.8.

The creep keeps its ceiling job. The ceiling is content-independent:
the largest `-c` that serves, the clean depth, the swap and compression
stops, the dead-server exit. What it cannot give is a drafter's speed.

The community measures speed at depth with real text. `llama-bench`
fills with random token ids and cannot measure a drafter at all.
`llama-benchy` fills with a Project Gutenberg book, and says why:
random tokens do not measure speculative decoding or MTP. llama.cpp's
own speculative-decoding doc points to SPEED-Bench, which reports
tok/s and acceptance side by side per prompt category.

The decision (owner, 2026-09-10): adopt `llama-benchy` for decode speed
at depth on every row that carries a drafter, at the server's own
sampling, and keep the creep for the ceiling. We are not scientists;
the number we want is the one the agent gets. This item checks that
benchy's numbers are those before any row reads from them.

## What llama-benchy has and lacks

Has: decode tok/s at a list of depths from real text, a warmup run,
repeats with a standard deviation, prefix reuse between depths, any
OpenAI-compatible server, markdown, JSON and CSV output, and
community-comparable numbers.

Lacks: memory sampling, stop conditions, dead-server detection from
the server log, an acceptance column, and a pause between depths. It
downloads a tokenizer from Hugging Face unless given a local path.
Sampling goes through `--extra-body`; with none, the server's own
default applies, which is what we want.

Two of those are recoverable inside the tool: `--post-run-cmd` runs a
shell command after each test, so it can sleep 60 s and append one
`vm_stat` line to a file; acceptance is in llama-server's log after
every request, which the runner reads.

## Mac procedure

Build: `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, rev `d562806`,
f16 KV, `--no-mmproj`, wired 25000. Two serving configs, in this order:

| arm | drafter flags | `-c` | depths |
| --- | --- | --- | --- |
| `none` | no `--spec-type`, no `--spec-draft-n-max` | 163840 | 4096, 49152, 98304 |
| `n3` | `--spec-type draft-mtp --spec-draft-n-max 3` | 131072 | 98304 |

Install: `pipx install llama-benchy`. Record the version. The
tokenizer is the base model's; pass `--tokenizer` with the repo the
quant's model card names, or a local path if the download is blocked.
Corpus: benchy's default book. The corpus only has to make the drafter
miss; if the `n3` cell reads acceptance above 95 percent, swap
`--book-url` to a text the model cannot have seen and re-run that one
cell. No temperature is passed: the server's default is the serving
sampling.

```bash
llama-benchy --base-url http://127.0.0.1:8081/v1 --model qwen3.8-27b \
  --tokenizer <base model repo> \
  --pp 512 --tg 256 --depth <depths for the arm> \
  --runs 2 --warmup-runs 1 \
  --post-run-cmd 'sleep 60; vm_stat | head -12 >> results/benchy-<arm>-vm.log' \
  --format md --save-result results/benchy-<arm>.md
```

Keep the server log for both arms; the acceptance line after every
request goes into the results beside its tok/s.

## Pass criteria

Read the `none` arm against the creep of 2026-09-09 (14.14 at 4K,
11.51 at 49K, 9.69 at 98K). Pass if every cell lands within 5 percent:
that shows the tool measures what the creep measures where content
does not matter.

Read the `n3` arm at 98K against the two numbers this item exists for:
the creep's 10.30 and the real-prompt cell's 7.89. Pass if it lands
near 7.89, at acceptance in the 60 to 80 percent range the agent runs
see. A reading near 10.30 with acceptance above 95 percent means the
corpus is memorised; swap the corpus and re-run that cell once.

Record acceptance for every cell. A row without it is not a drafter
measurement.

## What the result changes

Pass: the invocation that passed, the benchy version and the
tokenizer path go into `run4/state.md` as values, and benchmark run 14
reads them for its three benchy blocks. `docs/methodology/context-creep.md`
gains the rule that a drafter's speed at depth comes from benchy at
the server's sampling, and the creep's tok/s column on a drafter row
is a ceiling test only. The drafter tables on the model pages re-read
from the new numbers.

Fail on the tool: the creep's step prompt gets a real tail task at the
serving sampling with 256 tokens and an acceptance column, which is
the same fix built by hand, and run 14's benchy blocks wait.

The replacement of the creep's speed reader by benchy is its own item,
`unscheduled/benchy-monitor.md`, and waits on this one. The creep's
round-robin contexts, which the two-slot rows use, have no benchy
equivalent; the owner accepts the parallel measurement as the
fallback, and `unscheduled/benchy-round-robin.md` keeps the idle-slot
number through a fork and an upstream pull request.

## Cost

Two arms, one prefill of 98K each, four 256-token generations per
depth, about one hour with the server restarts.
