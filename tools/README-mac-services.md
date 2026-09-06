# Deciding what mac-services.sh disables

`tools/mac-services.sh` turns background items off before a run and puts them
back after. It ships with no list. A list of login items describes one
person's Mac, so it stays out of this repo.

Build your own list once. The script reads it every run.

## The three Mac setup steps

A Mac needs three setup steps before it can serve benchmark runs. Each
one is done once, and then again only when its own condition holds. A
run reads their results; a run never does them.

1. **The services list.** Decide what `mac-services.sh` disables. The
   rest of this page. Redo it when you install or remove an app that
   loads at boot.
2. **The wired limit.** Find the largest `iogpu.wired_limit_mb` this
   machine serves at, and the smaller value for when you work beside a
   run. The procedure is
   [the wired limit page](../docs/methodology/wired-limit.md). It needs
   `sudo` and it can need a reboot, so the owner must be present.
   Redo it after a macOS update, after a new model size class enters
   the cache, or after the services list changes.
3. **The machine file.** Write both results into
   `~/.config/choose-a-local-llm/machine.md`. Steps 1 and 2 are only
   finished when their values are in it, because
   [`tools/preflight.sh`](./preflight.sh) reads that file and nothing
   else. "Where your files go" and "What preflight reads" below give
   its shape.

Do them in that order. The services list changes the machine's resting
memory, so a wired-limit ladder run before it measures the wrong
machine.

## Where your files go

    ~/.config/choose-a-local-llm/
      machine.md                     this machine's values (below)
      services-user-agents.conf      labels to disable, one per line
      services-system-daemons.conf   labels that need sudo, one per line
      services-state                 written by "off", read by "on"
      baselines/                  the dumps you took before any change

`machine.md` is also the file `tools/preflight.sh` reads. See "What
preflight reads" below. It is the file the method pages point at for every value
that belongs to one machine and not to the method: the apps to handle
before a run and how (a firewall to set, an app to quit), the wired
limit, the free-memory threshold that skips the balloon, the server
size that needs a wired-recovery wait, ports, tool paths, and what was
observed on this machine (idle readings, a panic). Four sections:
"Apps to handle before a run" (a table: app, what to do, why),
"Thresholds", "Ports and paths", "Observed on this machine". Keep it
short; the setup page on the site carries the published numbers.

Blank lines and `#` comments are ignored. You can annotate a label with
why it is there, or comment one out to keep it running.

The script uses `$XDG_CONFIG_HOME` when it is set.

## What preflight reads

`tools/preflight.sh` checks the machine against this directory before a
run. It changes nothing and it needs no sudo. It reads:

- `machine.md`, "Apps to handle before a run". It takes the App column
  only. An app it has no check for becomes an `ask` line, so a new row
  never passes in silence.
- `machine.md`, "Thresholds". It takes the Setting cell of the
  `iogpu.wired_limit_mb` row and of the "Skip the balloon above" row,
  and reads the numbers out of it. A cell with two numbers ("24000
  unattended, 22000 when the owner also uses the machine") accepts
  both.
- `services-state`, through `mac-services.sh status`.
- `last-start-wired-mb`, when it exists: the wired MB value the last
  run recorded at its start. preflight compares the current wired
  value against it for the reboot check, and says nothing when the
  file is absent.

The table shape it expects is the one this page describes: a `## `
heading, then rows `| key | setting | note |`. Backticks around a key
are ignored. Every value has an environment override; `preflight.sh
--help` and its header list them.

The Little Snitch mode is not readable from userland on macOS: the
configuration is root-only and encrypted, and the `littlesnitch` tool
refuses to run without root. So preflight probes the outcome the mode
controls. It copies `node` (or `python3`) to a fresh path and connects
to the run port from there. An unapproved binary that reaches the port
is the "silently allow" outcome. This probe covers loopback traffic,
which is what a run makes; it says nothing about a download from the
internet.

## Reading the state, without changing it

    mac-services.sh status

`status` writes nothing. It prints the launchd state of every label in
the two `.conf` files, the widget setting, and the state file. Its last
line is for `preflight.sh`:

    summary: state=done recorded=21 drifted=1 com.docker.helper

`state=done` means `turn-off` already ran, so a run must not run it
again. `drifted` counts labels that `turn-off` disabled and that read
`enabled` again now.

## Step 1: take the baselines first

You cannot restore what you did not record. Take all three:

    sudo sfltool dumpbtm > ~/.config/choose-a-local-llm/baselines/btm-dump.txt
    launchctl print-disabled gui/$UID > ~/.config/choose-a-local-llm/baselines/disabled-user.txt
    launchctl print-disabled system > ~/.config/choose-a-local-llm/baselines/disabled-system.txt

`sfltool` needs root, and a terminal it can prompt in. An agent shell has
no TTY, so run this one yourself.

## Step 2: know that two stores disagree

`sfltool dumpbtm` reads Background Task Management. That is the store
behind System Settings > General > Login Items & Extensions. It is what
you see and toggle.

`launchctl print-disabled` reads launchd's own store. A different store.

An item can read `enabled` in one and `disabled` in the other. Trust BTM
for "is it on", because that is the switch you used. Use launchd for
items BTM does not list at all: older installs that never registered
with `SMAppService` are invisible in Settings, and `launchctl disable` is
the only way to reach them.

Read the BTM dump per UID. It covers UID 0, UID -2, and one section per
user account. Work in your own section.

## Step 3: find the orphaned helpers

This is the case that gives results. Turning off an app in Settings
stops the app auto-starting. It does not touch that app's separate
helper agent, which keeps loading at every boot.

Look for an app record with `Disposition: [disabled ...]` whose vendor
also has a `login item` or `legacy agent` record still marked `enabled`.
Those helpers are the first thing on your list. Disabling them only
finishes a decision you already made.

## Step 4: sort what is left into three groups

- **Disable for a run.** Updaters, sync clients, menu bar extras, backup
  agents. Nothing a benchmark needs. This is the list you write.
- **You decide.** Anything with a cost you will feel: a password manager
  helper, an audio driver stack. Keep these commented out with the cost
  written next to them.
- **Cannot be disabled this way.** Network system extensions. Check with
  `systemextensionsctl list`. Only the parent app can remove one, through
  System Settings > General > Login Items & Extensions > Network
  Extensions. Disabling the vendor's launch agent does not unload the
  extension.

## Step 5: measure, do not assume

A disabled item that is already running keeps running, so a saving is
only real after a reboot.

1. Record both stores.
2. Reboot. Wait a fixed settle time. Record `vm_stat` and the process
   list. That is baseline A.
3. `mac-services.sh turn-off`.
4. Reboot. Same settle time. Record the same two. Baseline B.
5. The delta between A and B is the true saving.
6. `mac-services.sh restore` when the run is done.

Judge the delta against what you are trying to fix. Background login
items are measured in hundreds of megabytes. If your failure is a model
server that did not release tens of gigabytes, this list is not the
cause and turning it off will not help.

## Reversing

`on` reads `services-state`, which `off` wrote. It re-enables exactly the
labels it disabled and nothing else, so it cannot undo a toggle you set
by hand.

Settings toggles cannot be scripted at all. `sfltool` has `dumpbtm` and
`resetbtm` only, with no way to enable one item. Flip those back by hand,
using your BTM baseline as the record. Never run `resetbtm`; it wipes
the whole list.
