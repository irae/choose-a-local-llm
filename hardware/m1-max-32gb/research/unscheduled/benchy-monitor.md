# Replace the creep's speed reader with llama-benchy, keep the creep as the monitor

Status: unscheduled, filed 2026-09-10. Origin: the `benchy-ab` item in
`../benchy-ab.md`; this item waits on its result. Needs hardware: yes,
for the validation runs at the end; the build itself is desk work.

## The idea

`llama-benchy` fills the context with real text, reads the decode
speed at a list of depths, warms up, repeats, and streams one JSON
event per finished test through `--emit-progress`. The creep owns
everything benchy lacks, and all of it is method work: the 60 s pause,
the `vm_stat` sample per rung, the floor, swap-growth and compression
stops, the server-log liveness read, the dead-server exit 42, the
tab-separated record with wired first.

`CONVENTIONS.md` already asks for that split: one module owns the
method, a thin adapter owns the backend. Today the adapters are
`backend_llama.py`, `backend_mlx.py` and `backend_lmstudio.py` in
`local-llm-eval-tools/slow-context-creep`, each building its own
prompt and reading its own timings. After this item benchy is the one
adapter and the three files go.

## The shape

Rung by rung. The monitor calls benchy with one `--depth` at a time,
reads the rung's event, samples memory, applies the stop rules, pauses
60 s, and goes on to the next rung. Prefix reuse keeps each rung as
cheap as a creep step: the deepest rung pays one prefill of the new
block only. The monitor's own output keeps the creep's columns, with
two additions: the acceptance rate the server log printed for the
rung's requests, and benchy's standard deviation across its repeats.

The stop rules, the pause and the record are unchanged. The verdict
line is unchanged. A run that ran under a changed silence or pause
value says so, as today.

## What changes for the two-slot rows

The creep's round-robin `N_CONTEXTS`, two prompts grown in turn on one
server, has no benchy equivalent. Benchy's `--concurrency` runs the
slots in parallel, which measures both slots decoding at once. The
owner accepts that trade (2026-09-10): the two-slot rows move to the
parallel measurement, which is the worst case and not the idle-slot
case the site reports today. The comparison page's "tok/s
(shallow → deep)" rule for multi-slot rows, one slot decoding alone,
has to change with it, and every two-slot row gets re-measured before
its number is replaced. The fork item in `benchy-round-robin.md` is
the other way out.

## Pinning

Benchy is a third-party tool that moves. The run records its version
the way it records the creep hash today, and a run never upgrades it
mid-way. The `--book-url` corpus is pinned by URL and token count in
the same place, because a changed corpus changes the acceptance.

## Validation before any row reads from it

Two rows re-measured with the merged tool against their creeps: one
no-drafter row, where the numbers must agree within 5 percent at every
rung, and one drafter row, where the merged tool must land near the
real-prompt cell and record its acceptance. The `benchy-ab` item is
the first of those two; the second is any drafter row of another
model.
