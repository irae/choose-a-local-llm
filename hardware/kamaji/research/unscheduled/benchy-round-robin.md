# Fork llama-benchy for a round-robin mode, and offer it upstream

Status: unscheduled, filed 2026-09-10. Origin: `benchy-monitor.md`,
which loses the creep's round-robin contexts when benchy becomes the
speed reader. Needs hardware: only for the check at the end.

## Why

The site's multi-slot rows report one slot decoding alone with the
other slots loaded and idle, because that is what separate agent
sessions keeping their own cache look like. The creep measures it
with `N_CONTEXTS`: two prompts, each append-only with a disjoint
block-number range, grown in turn on one server. Benchy has
`--concurrency`, which fires the slots at once and measures them under
load. That is a different number, the worst case, and the owner
accepts it as the fallback (`benchy-monitor.md`). This item keeps the
idle-slot number without keeping the old creep alive for it.

## What the change is

A `--round-robin N` option, or a `--concurrency N --sequential` pair,
that holds N independent contexts, each filled from a different offset
of the corpus so no two share a prefix, and at every depth runs the
tests for context 1, then context 2, and so on, one at a time, so the
other slots stay loaded and idle while one decodes. The report carries
one line per context per depth, the way the creep's TSV does. The
prefix reuse benchy already does per context must hold per slot, which
llama-server's slot cache gives when the prompts differ from the first
token.

## How

Fork `eugr/llama-benchy`, pin the fork's commit in the run record the
way the creep hash is pinned today, and open a pull request upstream
with the option and a paragraph on why idle-slot decode is a different
measurement from concurrent decode. If upstream takes it, the fork
goes and the pin moves to a released version. If upstream declines,
the fork stays as the project's pinned build, an approved exception of
the same kind as the PrismML llama.cpp fork.

## Check

One two-slot row measured three ways on the same server: the creep's
round-robin, the fork's round-robin, and benchy's concurrency. The
first two must agree within 5 percent rung for rung. The third is
recorded beside them as the worst case and stays off the site's
one-slot-decoding cell.
