# Goal 0 — the boot-item audit

The machine's own list is not in this repo. A list of login items names
the owner's apps, so it lives in
`~/.config/choose-a-local-llm/boot-inventory.md`, with the raw dumps in
`~/.config/choose-a-local-llm/baselines/`.

The method is in `tools/README-mac-quiet.md`. What follows is what the
audit taught, not what it found on one Mac.

## Two stores disagree, and only one is the switch the owner used

`sfltool dumpbtm` reads Background Task Management, the store behind
System Settings > General > Login Items & Extensions. `launchctl
print-disabled` reads launchd's own store. They are separate.

Items read `enabled` in launchd and `disabled` in BTM at the same time.
An earlier version of this audit used `launchctl print-disabled` alone
and got the state wrong for a dozen items. BTM is the switch the owner
used, so BTM wins for "is it on".

Some items have no BTM record at all. Older installs that never adopted
`SMAppService` never appear in Settings, so the owner cannot see them
and `launchctl disable` is the only way to reach them.

## The orphaned helper is the case that pays

Turning an app off in Settings stops the app auto-starting. It leaves
that app's separate helper agent enabled, and the helper still loads at
every boot.

On the audited machine, of 14 app records the owner had disabled, 12
had kept a helper enabled. Only two apps were off all the way through.
The owner believed they had turned these apps off, and they had — the
switch they used does not reach the helper.

Any pre-run gate that reads the Settings list will therefore report a
machine as quieter than it is.

## System extensions are outside all of this

A network system extension cannot be unloaded by disabling a launchd
label or a login item. Only the parent app removes it. The proof on the
audited machine: an app record was disabled and its network extension
was still running.

## Scale check

Background login items are worth hundreds of megabytes in total. The
dagger-sweep OOM in `benchmarks/bench7/state.md` (H1) began with free
memory pinned at 60-220 MB because a model server holding tens of
gigabytes had not released it.

A gate built on a login-item denylist would have passed that run. The
gate has to measure free memory against an idle baseline and wait for
recovery. That work is not done.
