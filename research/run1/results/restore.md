# How to put this Mac back

Read this before you assume something is broken.

Nothing here names a machine. The owner's own state lives in
`~/.config/choose-a-local-llm/`, outside the repo.

## Desktop widgets — currently OFF

Turned off 2026-09-03 at the owner's request. To turn back on:

    defaults write com.apple.WindowManager StandardHideWidgets -bool false
    killall WindowManager

The layout is not affected either way. Every widget instance lives in
`~/Library/Group Containers/group.com.apple.chronod/chronod/chrono.sql`,
table `HostConfigs`, one row. The toggle never writes to it. A backup of
the 2026-09-03 state is in the owner's home directory.

iPhone widgets are a separate switch the owner controls in Settings. No
agent touches it.

## launchd items

* script: `tools/mac-quiet.sh off` and `tools/mac-quiet.sh on`
* method: `tools/README-mac-quiet.md`
* lists: `~/.config/choose-a-local-llm/quiet-*.conf`
* state file: `~/.config/choose-a-local-llm/quiet-state`, written by
  `off`, read by `on`
* scope: `on` restores only what `off` disabled, nothing else
* effect: needs a reboot both ways

## Baselines taken before any change

In `~/.config/choose-a-local-llm/baselines/`: the BTM dump, and
`launchctl print-disabled` for both domains, all dated 2026-09-03.

## Settings toggles cannot be scripted

`sfltool` has `dumpbtm` and `resetbtm` only. There is no supported way
to re-enable a Background Task Management item from the command line.
`resetbtm` wipes the whole list — never run it.

A toggle flipped in System Settings > General > Login Items &
Extensions must be flipped back by hand. The BTM baseline is the record
of what was on before.
