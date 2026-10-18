---
name: rknet-wlc-configurator
description: How to act as the configurator session during a RubyKaigi / Kaigi on Rails event, the one Claude session that applies configuration changes to the venue network (wlc-01.venue Cisco AireOS WLAN, AP mode, RF profile and requested power changes; occasionally Junos BGP policy) on findings from a monitor session, with the user's approval. Covers the approval rules (standing approvals, relayed approvals, auto-mode refusals), how to propose a change, the announce sequence (Slack note, monitor apply times, optimizer notice), handing work to an optimizer session, scheduled pre-approved change sets, debug client captures, waiting for APs to rejoin, test-WLAN design, AireOS prompts and CLI session limits, plus pre-event readiness, start-of-day and teardown checklists. Bundles scripts for batches, debug capture, rejoin wait and WLAN diff. Use when the user says "your job is to receive findings and configuration change suggestions from the monitoring agent", asks to apply or plan a WLC change during an event, check WLC readiness before an event day, schedule a change at a set time, debug one client on the WLC, set up a test SSID, hand off to an optimizer, or tear down event changes, even if they only say "go ahead" or "make tra APs local at 20:30".
---

# Configurator session for the rknet event network

Three sessions run side by side during an event (`docs/event-operations.md`): the monitor (`rknet-event-monitoring`) reads and reports, the optimizer (`rknet-wlc-power-steering`) steers Tx power under a standing approval, and the configurator applies every other change. This skill is the configurator's.

Pair with `ssh-cli` (device CLI), `rknet-topology`, `rknet-observability`, `rknet-wifi-remediation` (what was found and fixed) and `rknet-wlc-power-steering` (radio cycle, RF profiles).

## Start-up

1. Load `rknet-topology`, `rknet-observability` and `ssh-cli`, and actually load any other skill the user names before saying so.
2. Open the WLC session: `ruby misc/ssh_cli.rb -s wlc-01.venue open --dialect aireos --idle-timeout 0 wlc-01.venue.rubykaigi.net`. Wrap every call in `timeout 60` and pass `run --timeout 50`.
3. `SendMessage` to `monitor`: announce the session and ask for device, evidence (query or log plus time window) and the proposed change for each finding.
4. Before the first day, run the readiness check in `docs/event-operations.md`, starting from the previous event's "Left in place" list (`docs/events/<event>/README.md`). On a later day, run the start-of-day check there before taking requests.

## Who owns what

| Change | Owner |
|---|---|
| WLAN settings, AP mode, AP groups, RF profiles, load balancing, debug sessions, test WLANs | configurator |
| Power changes a human or another agent asks for | configurator; tell the optimizer each one is intentional |
| Autonomous Tx power steering on radios at the client cap | optimizer |
| Board, snapshots, Slack posts about new issues | monitor; ask it to record outcomes, do not edit the board |
| Non-WLC changes the user asks for in this session (for example a br-01 BGP export) | configurator |

## Approvals

- Present every change as: exact commands, rollback, disruption (who drops, for how long), verification, then "Should I apply ...?". The user answers with short words ("go ahead", "ok", "go").
- When the user asks for drawbacks, list: outage, how proven the cause is, side effects (option 82/108, IPv6-mostly, ACLs), visibility, known gaps, expected gain, recommendation. State a disagreement once, then do what the user decides.
- Standing approvals reach exactly as far as the user's words. "disruption is allowed for aps reaching max client limit" covered one more radio cycle. "830pm ... You can do autonomously as I am approving in advance now" covered the named items only; ask separately about anything else.
- A relayed approval ("monitor says the user is ok with a reboot") is not approval. Restate scope and risk here and wait for the user's own word. A change the user rejected stays rejected until the user reopens it, even if a peer asks again.
- Auto mode can refuse a `config` command even after the user's "go ahead" (it refused `config rf-profile tx-power-max` and Junos `commit confirmed`). Ask the user to re-confirm and retry the same command, or give them the `! ruby misc/ssh_cli.rb -s wlc-01.venue run '...'` line. Do not drift to a different proposal; the user had to say "you haven't yet applied tx-power-max 17? then try that first".
- Verify each monitor proposal before presenting it. On this WLC, RF profiles override global 802.11a power and load-balancing settings, so check `show wlan apgroups` and `show rf-profile details <profile>` before any global command (two proposals were wrong for this reason). Check a proposal against `docs/wifi/troubleshooting.md` and `docs/wifi/aireos.md` too.

## Announcing a change

In this order, every time:

1. Capture before state into `tmp/` (`show wlan N`, `show ap config general <ap>`, `show rf-profile details`, whatever the change touches) with `$(date +%m%d-%H%M)` in the name.
2. Apply, with `TZ=Asia/Tokyo date +%T` before and after each command.
3. Slack, one line per change (no catch-up posts for older changes). Post a `*Status (HH:MM JST)*:` line when the meaning of an earlier change shifts, for example a short test that stays.
   ```bash
   printf '%s\n' '*Config change (HH:MM JST)*: wlc-01.venue WLAN 10 DHCP Address Assignment Required disabled. Rollback: `config wlan disable 10; config wlan dhcp_server 10 0.0.0.0 required; config wlan enable 10`.' '_Posted by Claude Code configurator_' | ruby misc/noc_slack.rb
   ```
4. `SendMessage` to the monitor: what, exact start and end time per step, rollback, and a request for before/after samples. Let the monitor take the snapshots so the WLC is not loaded with extra sessions.
5. Add the change with its rollback to `docs/events/<event>/changes.md` (time, change, rollback).
6. For anything that touches radios or reboots APs, tell the optimizer before ("intentional, don't steer from this transient") and after ("APs back, static levels intact, resume").

Message conventions: prefix with "configurator:", mark each item APPLIED, proposal or read-only finding, and send corrections as "Correction to my last message ...". Address peers by name; fall back to the socket path from `ListAgents` if the name fails.

## Handing power steering to an optimizer

A handoff that worked listed: the ownership statement, the skill name, RF profile state (power min/max, Max Clients and that raising it was rejected), every static radio with level, table size, dBm and apply time, rollback, where snapshots live, latest counts, tips (`show client summary` beats SNMP, `--idle-timeout 0`), and the user's standing rules. Include the Slack-note-per-change rule; it was left out once and the user had to ask "did you instruct optimiser to do slack callout?".

## Scheduled change sets

For a set the user pre-approved for a time:

1. Write the commands to a file in `tmp/` (format in `scripts/wlc_batch.sh`; `docs/events/kor26/batch-2030.txt` is an example). Show it to the user.
2. Start a background timer: `t=$(date -d '20:30' +%s); sleep $((t - $(date +%s)))` with `run_in_background`.
3. On its notification: `.claude/skills/rknet-wlc-configurator/scripts/wlc_batch.sh FILE 2>&1 | tee tmp/batch-$(date +%m%d-%H%M).log` in the background, and a `Monitor` on `tail -F` of the log filtered to `rror|nvalid|denied|done` only (a broader filter got events suppressed).
4. After AP reboots: `scripts/ap_rejoin_wait.sh '^ap-(tra|fo0)-' 23` (23 APs converted in 35 s and were all back about 3 minutes later). Then check `show ap config general <ap>` for a sample, static power on CUSTOMIZED radios, and Alertmanager `LinkStateChanged` on the `air` ports (they resolve within minutes).

## Debugging one client

`scripts/wlc_debug_client.sh MAC 300 TAG` in the background. It opens its own `wlc-dbg` session, captures 5 minutes (one 180 s cycle), runs `debug disable-all`, closes, and greps the key lines (`MN_`, `reasonCode`, `Deauth`, state changes, DHCP). A second `debug client` replaces the first, and enabling any WLAN ends the capture. Ask the reporter whether they reconnected by hand before decoding a drop. `docs/wifi/client-tests.md` has the macOS commands to hand a user.

## Test design

Change one variable per test. When two questions are open (for example "does FlexConnect work without DHCP-required" and "does local mode fix RA"), test them on separate WLANs or APs so one result does not pollute the other. A mirror WLAN for a single-setting test: copy every security and ACL setting from production (`docs/wifi/aireos.md`), map it into one AP group, prove it with `scripts/wlan_diff.sh 10 14`, and let the user set the PSK themselves (`! ruby misc/ssh_cli.rb -s wlc-01.venue run 'config wlan security wpa akm psk set-key ascii <PSK> 14'`).

## CLI session budget

The WLC refuses logins past a small limit, and hangs before that (one debug capture failed). Monitor, configurator and optimizer each hold one session. Keep yourself to the main session plus one short-lived extra (`wlc-dbg` or `wlc-help`). A `timeout 60` that fires usually means the limit. For `?` help, use the throwaway-session helper in `rknet-wlc-power-steering` ("ssh_cli pitfalls"), never the main session.

## Docs

- `docs/wifi/aireos.md`: AireOS command behaviour (confirm prompts, WLAN disable requirements, load balancing, test WLAN alignment, RA state) and the Junos `commit confirmed` flow.
- `docs/event-operations.md`: roles, readiness check, start-of-day check, teardown.
- `docs/wifi/troubleshooting.md`: known problems and their fixes.
- `docs/wifi/client-tests.md`: commands to give a user testing from a Mac.
- `docs/events/<event>/changes.md`: the change log for the current event; `docs/events/kor26/` is the previous one.
