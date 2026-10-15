---
name: ssh-cli
description: Drive interactive CLI sessions on RubyKaigi network devices (Junos br/er/cs/as, NEC IX tun, Cisco IOS es, Cisco AireOS wlc) over SSH, one command per call, with secrets masked by glazed. Use when asked to SSH into a router or switch, run show commands on a device, check device state, or inspect device configuration.
allowed-tools: Bash(ruby misc/ssh_cli.rb:*)
---

# Device CLI sessions with misc/ssh_cli.rb

`misc/ssh_cli.rb` keeps an SSH session in a background daemon, so each Bash call runs one device command and prints only that command's output. Logging in costs an SSH handshake and an ssh-agent signature, which may need the user to touch a key, so keep sessions open and reuse them rather than reconnecting. All output passes through glazed's redactor for the session's dialect before it reaches you or the log. Masked values look like `[~REDACTED:dgst=…~]`. Within one session the same secret always gets the same digest, so you can compare them, but never try to recover the value.

Setup, once: `(cd glazed && bundle install)`.

## Quick start

```bash
ruby misc/ssh_cli.rb -s br-01.nrt open --dialect junos br-01.nrt.rubykaigi.net
ruby misc/ssh_cli.rb -s br-01.nrt run 'show interfaces terse'
ruby misc/ssh_cli.rb -s br-01.nrt run 'show configuration protocols bgp'
```

The dialect has to match the device, because it decides both prompt detection and secret masking. `glazed/glazed.jsonnet` has the mapping:

| Devices | Dialect | Login |
|---|---|---|
| br-01, er-*, cs-*, as-* (Juniper) | `junos` | SSH key |
| tun-*, nat-*, recon-* (NEC IX) | `nec_ix` | NOC password |
| es-* (Cisco IOS) | `ios` | NOC password |
| wlc-* (AireOS) | `aireos` | NOC password |

## Commands

```bash
ruby misc/ssh_cli.rb [-s NAME] open --dialect DIALECT [--mask-env VAR]... [--timeout SEC] [--idle-timeout SEC] HOST
ruby misc/ssh_cli.rb [-s NAME] run [--timeout SEC] 'COMMAND'
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

- Sessions are private to your Claude Code session. Other agents' sessions are invisible, and yours end when your Claude Code process exits.
- Name each session after its device with `-s`, such as `-s br-01.nrt` and `-s tun-01.hnd`, so sessions to several devices stay open side by side and are easy to find again.
- Run `list` first to see which sessions are already open, with their dialect, idle time and target.
- `open` on a live session to the same target and dialect reuses it without logging in again. It only prints output that arrived since the last command. A session under that name open to a different target is an error.
- Don't `close` a session when a task ends. It shuts itself down after an hour without commands (`--idle-timeout SEC` changes it, `0` disables it). Close it only when the user asks.
- Exit status 2 from `run` means the session is gone, because it idled out or the device dropped it. `open` it again.
- State lives in `tmp/ssh-cli/<session id prefix>/`, and `NAME.log` keeps the redacted transcript.

## Passwords and prompts

- Junos devices log in with keys from `~/.ssh/config`.
- Every other dialect logs in with the NOC password, which glazed reads from SSM and hands to SSH as a credential, so you never see or type it. It needs AWS credentials that can read the parameter. Never fetch that password yourself (`aws ssm get-parameter`, `send --secret-ssm`, or anything else).
- Sessions are glazed NodeSessions over net-ssh, which reads `~/.ssh/config` for the user and jump host. After login, `open` runs the dialect's post-login commands, such as `terminal length 0` or `config paging disable`.
- If `open` fails with `cannot log in`, tell the user what it printed rather than retrying. A rejected password or an unknown host key both end up there.
- Never put a password in `send 'TEXT'`. Use `send --secret-ssm NAME` or `send --secret-env VAR`, which types the value without it showing up in the command line or output. From then on, the session masks that value everywhere.
- If you don't know where a secret lives, ask the user. Don't guess.

## Output

- Pagers (`---(more)---`, `--More--`) are answered automatically. Adding `| no-more` on Junos is still cheaper for long output.
- Commands that run until interrupted (`ping` without `count`, `monitor`) time out with partial output. Stop them with `send --ctrl c`. Prefer `ping 192.0.2.1 count 3` and similar.
- If `run` times out on a command that should have finished, the prompt didn't match the dialect's. Check `read --tail 5` and tell the user.

## Limits

- Masking only covers what the dialect's patterns and the values you sent or passed to `--mask-env` match. A secret the dialect doesn't know about, such as one in a file printed from a shell, can still come through.
- Read-only by default. Never enter `configure`, `commit`, `request`, `clear`, `restart`, or a command that changes device state unless the user explicitly asks for that change.
