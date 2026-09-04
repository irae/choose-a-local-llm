# mac-services.sh — how to decide what to disable

`tools/mac-services.sh` turns background items off before a run and puts them
back after. It ships with no list. A list of login items describes one
person's Mac, so it stays out of this repo.

Build your own list once, then the script reads it every run.

## Where your files go

    ~/.config/choose-a-local-llm/
      services-user-agents.conf      labels to disable, one per line
      services-system-daemons.conf   labels that need sudo, one per line
      services-state                 written by "off", read by "on"
      baselines/                  the dumps you took before any change

Blank lines and `#` comments are ignored, so you can annotate a label with
why it is there, or comment one out to keep it running.

`$XDG_CONFIG_HOME` is used when set.

## Step 1 — take the baselines first

You cannot restore what you did not record. Take all three:

    sudo sfltool dumpbtm > ~/.config/choose-a-local-llm/baselines/btm-dump.txt
    launchctl print-disabled gui/$UID > ~/.config/choose-a-local-llm/baselines/disabled-user.txt
    launchctl print-disabled system > ~/.config/choose-a-local-llm/baselines/disabled-system.txt

`sfltool` needs root, and a terminal it can prompt in. An agent shell has
no TTY, so run this one yourself.

## Step 2 — know that two stores disagree

`sfltool dumpbtm` reads Background Task Management. That is the store
behind System Settings > General > Login Items & Extensions. It is what
you see and toggle.

`launchctl print-disabled` reads launchd's own store. Different store.

An item can read `enabled` in one and `disabled` in the other. Trust BTM
for "is it on", because that is the switch you used. Use launchd for
items BTM does not list at all — older installs that never registered
with `SMAppService` are invisible in Settings, and `launchctl disable` is
the only way to reach them.

Read the BTM dump per UID. It covers UID 0, UID -2, and one section per
user account. Work in your own section.

## Step 3 — find the orphaned helpers

This is the case that pays. Turning off an app in Settings stops the app
auto-starting. It does not touch that app's separate helper agent, which
keeps loading at every boot.

Look for an app record with `Disposition: [disabled ...]` whose vendor
also has a `login item` or `legacy agent` record still marked `enabled`.
Those helpers are the first thing on your list. Disabling them only
finishes a decision you already made.

## Step 4 — sort what is left into three groups

- **Disable for a run.** Updaters, sync clients, menu bar extras, backup
  agents. Nothing a benchmark needs. This is the list you write.
- **You decide.** Anything with a cost you will feel — a password manager
  helper, an audio driver stack. Keep these commented out with the cost
  written next to them.
- **Cannot be disabled this way.** Network system extensions. Check with
  `systemextensionsctl list`. Only the parent app can remove one, through
  System Settings > General > Login Items & Extensions > Network
  Extensions. Disabling the vendor's launch agent does not unload the
  extension.

## Step 5 — measure, do not assume

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
using your BTM baseline as the record. Never run `resetbtm` — it wipes
the whole list.
