---
name: ssh-cli
description: Drive interactive CLI sessions on RubyKaigi network devices (Junos br/er/cs/as, NEC IX tun, Cisco AireOS wlc) over SSH, one command per call, with secrets masked by glazed. Use when asked to SSH into a router or switch, run show commands on a device, check device state, or inspect device configuration.
allowed-tools: Bash(ruby misc/ssh_cli.rb:*)
---

# Device CLI sessions with misc/ssh_cli.rb

`misc/ssh_cli.rb` keeps an SSH session in a background daemon, so each Bash call runs one device command and prints only that command's output. All output passes through glazed's redactor for the session's dialect before it reaches you or the log. Masked values look like `[~REDACTED:dgst=…~]`. Within one session the same secret always gets the same digest, so you can compare them, but never try to recover the value.

Setup, once: `(cd glazed && bundle install)`.

## Quick start

```bash
ruby misc/ssh_cli.rb open --dialect junos -- br-01.nrt.rubykaigi.net
ruby misc/ssh_cli.rb run 'show interfaces terse'
ruby misc/ssh_cli.rb run 'show configuration protocols bgp'
ruby misc/ssh_cli.rb close
```

The dialect has to match the device, because it decides both prompt detection and secret masking. `glazed/glazed.jsonnet` has the mapping:

| Devices | Dialect |
|---|---|
| br-01, er-*, cs-*, as-*, es-* (Juniper) | `junos` |
| tun-* (NEC IX) | `nec_ix` |
| wlc-* (AireOS) | `wlc` |

## Commands

```bash
ruby misc/ssh_cli.rb [-s NAME] open --dialect DIALECT [--prompt RE] [--mask-env VAR]... [--timeout SEC] -- <ssh args...>
ruby misc/ssh_cli.rb [-s NAME] run [--timeout SEC] [--prompt RE] 'COMMAND'
ruby misc/ssh_cli.rb [-s NAME] send [--no-newline] 'TEXT'          # answer y/n, yes/no confirmations
ruby misc/ssh_cli.rb [-s NAME] send --ctrl c                       # interrupt
ruby misc/ssh_cli.rb [-s NAME] send --secret-ssm /glazed/prd/password
ruby misc/ssh_cli.rb [-s NAME] send --secret-env VAR
ruby misc/ssh_cli.rb [-s NAME] wait [--until RE] [--timeout SEC]
ruby misc/ssh_cli.rb [-s NAME] read [--tail N]
ruby misc/ssh_cli.rb list
ruby misc/ssh_cli.rb [-s NAME] close [--all]
```

Exit status: 0 ok, 1 timed out (output may be partial), 2 no such session, or the session closed.

## Sessions

`-s NAME` (default `default`) lets you keep several devices open at once, such as `-s nrt` and `-s hnd`. State lives in `tmp/ssh-cli/`, and `NAME.log` keeps the redacted transcript.

## Passwords and prompts

- `open` stops at a password, username or host key prompt and prints it. Junos devices log in with keys from `~/.ssh/config`.
- Never put a password in `send 'TEXT'`. Use `send --secret-ssm NAME` or `send --secret-env VAR`, which types the value without it showing up in the command line or output. From then on, the session masks that value everywhere.
- If you don't know where a secret lives, ask the user. Don't guess.

## Output

- Pagers (`---(more)---`, `--More--`) are answered automatically. Adding `| no-more` on Junos is still cheaper for long output.
- Commands that run until interrupted (`ping` without `count`, `monitor`) time out with partial output. Stop them with `send --ctrl c`. Prefer `ping 192.0.2.1 count 3` and similar.
- If `run` times out on a command that should have finished, the prompt didn't match. Check `read --tail 5`, then retry with `--prompt RE`.

## Limits

- Masking only covers what the dialect's patterns and the values you sent or passed to `--mask-env` match. A secret the dialect doesn't know about, such as one in a file printed from a shell, can still come through.
- Read-only by default. Never enter `configure`, `commit`, `request`, `clear`, `restart`, or a command that changes device state unless the user explicitly asks for that change.
- Always `close` the session when you're done.
