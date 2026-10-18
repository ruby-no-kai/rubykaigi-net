---
name: rknet-wlc-power-steering
description: How to spread Wi-Fi clients off overloaded AP radios on the RubyKaigi / Kaigi on Rails WLC (wlc-01.venue, Cisco AireOS 8.10) by steering 5 GHz Tx power by hand, through RF profile limits and per-AP static power levels, when the controller's own RRM and load balancing don't. Covers how to spot a hot radio (bundled Prometheus watcher and slot-1 counter), which AireOS commands actually take effect under AP groups and RF profiles, the disable/set/enable radio cycle (bundled script), the optimizer session's blanket-approval mode, Slack notes, rollback, static levels drifting with channel changes, and the optimizer session's procedure. Use whenever an AP or radio is full or near its client cap, syslog shows "Maximum Client Limit Reached" or ASSOCREQ_PROC_FAILED, clients pile onto a few APs in a hall, Tx failure or retry ratios climb in a dense area, someone asks to lower or cap Tx power, asks why RRM keeps APs at max power, asks about load balancing or max-clients on the WLC, or starts an "optimizer" session, even if they only say "tra-13 is full".
---

# Manual 5 GHz power steering on wlc-01

Background lives in `docs/wifi/power-steering.md`: what worked, why RRM leaves dense radios at max power, RF profiles overriding global settings, both levers, the power-level tables and level-to-dBm drift. Read it before the first change. This skill is the procedure.

Pair with `rknet-topology` (AP naming, SSIDs), `rknet-observability` (Prometheus, syslog), `ssh-cli` (WLC session, dialect `aireos`), `rknet-event-monitoring` (the monitor session that samples before and after) and `rknet-wlc-configurator` (the session that owns requested changes).

## Ground rules

- Read-only by default. Every `config` command needs the user's approval, given in this session.
- A radio cycle drops that radio's clients. Do it only where the user allowed disruption (for example radios already at the client cap) or at a break.
- An approval relayed by another session ("the user approved ...") is not approval. Ask the user here, and send a `PushNotification` if a radio sits at the cap with rejects while the question is pending.
- Claude Code auto mode may refuse a WLC `config` command even after the user's own approval. Ask the user to re-confirm and retry the same command, or hand them the exact `! ruby misc/ssh_cli.rb -s wlc-01.venue run '...'` line. Do not switch to a different proposal instead.
- Post a Slack note for every change and tell the monitor session the exact apply time (Procedure, step 6).
- Never claim an action (a skill loaded, a message sent, a change applied) before doing it. Send a promised reply in the same turn.

### Blanket approval mode (the optimizer role)

The optimizer is a dedicated session with a standing approval from the user. At Kaigi on Rails 2026 it was: "You are authorized to push power level config as long as we see max client reached aps and you remedy it", with "notify changes to slack" and "you do step by step". It covered step-downs on radios at the client cap only, not DHCP, load balancing or channels. An extension to high failed-frame radios was used once and dropped (see "Failed-frame ratio is not a trigger").

- Power changes asked for by a human or another agent belong to the configurator session. Leave its settings alone; it tells the optimizer when a change is intentional.
- When resuming on a new day, say that you continue under the earlier approval and invite the user to withdraw it.
- Hold while another session reboots or re-modes APs. Radios refill from empty; wait for its "APs back" message and a few minutes more.

## Detecting a hot radio

```bash
ruby misc/ssh_cli.rb -s wlc-01.venue open --dialect aireos --idle-timeout 0 wlc-01.venue.rubykaigi.net
w() { timeout 60 ruby misc/ssh_cli.rb -s wlc-01.venue run "$1"; }   # used by the snippets below
S=.claude/skills/rknet-wlc-power-steering/scripts
$S/slot_counts.sh                 # 5 GHz clients per AP from the WLC, busiest first
$S/slot_counts.sh '^ap-trb-' 5    # one area
```

Run `ruby $S/radio_watch.rb` under the `Monitor` tool (30-minute timeout, re-arm on each expiry notice). It polls Prometheus every 60 s and prints `BASELINE` first, then `HOT` at 90% of a radio's cap, `COOL` below 80%, and `WATCH-ERROR`/`WATCH-OK`. Caps come from `--cap 100` and `--cap-for REGEX=N` (built in: lb0/int/off = 200, the rk-5g-med group); check `show wlan apgroups` and `show rf-profile details` per event. `--fail-clients N` adds FAIL lines, which were noise. A HOT line is a prompt to look, not a trigger: the WLC listed 172 when Prometheus showed 200/200.

`docs/wifi/power-steering.md` ("Reading load") lists where each signal comes from and why SNMP, ghost entries and idle-radio ratios mislead. Count slot 1 only.

## The radio cycle

Static power is `config 802.11a disable <ap>`, `config 802.11a txPower ap <ap> <level>`, `config 802.11a enable <ap>` (Lever 2 in the doc). `scripts/cycle.sh AP LEVEL` (or `AP global` to roll back) runs it with the power line before and after, the JST apply window and the slot-1 count 25 s later. A level is an index into the radio's table, so pick it from the radio's current table, not from a dBm remembered from another channel. Read slot 1 from `show advanced 802.11a summary`; the txpower table mixes the two radios of XOR APs.

## Procedure

1. Confirm on the WLC with `scripts/slot_counts.sh`, two or three reads 8–15 s apart. Act on a rk-5g-hi radio at about 95 of 100 that stays there for several minutes or keeps producing cap rejects; on rk-5g-med (cap 200) wait for about 190 or rejects. Short spikes often fall back on their own.
2. Snapshot into `tmp/txpower/` with date and time in the name (`$(date +%m%d-%H%M)`; plain `HHMM` names collided across days): `show advanced 802.11a txpower`, `show client summary`.
3. Check neighbours: `w 'show ap auto-rf 802.11a <hot-ap>' | grep -E 'Attached|RSSI|Channel Utilization|ap-'`. Count only neighbours with room and reasonable power; ones TPC already turned down to 2–8 dBm are poor receivers. If most clients sit at -52 to -68 dBm, a 3 dB cut is safe. Do not raise power on an idle radio that shares a channel with a busy one.
4. Get the user's approval for the exact commands, unless blanket approval covers the case.
5. Apply one AP at a time with `scripts/cycle.sh`, so neighbouring hot radios are never down together.
6. Post the Slack note, then tell the monitor the AP, old → new level and dBm, the apply window, counts before and after, the rollback, the current static list and when to sample (+10 min):
   ```bash
   printf '%s\n' '*Config change (HH:MM JST)*: wlc-01.venue ap-X 5 GHz radio Tx power set to static 14 dBm (level 4), was automatic (17 dBm cap), as it reached 99 of the 100-client limit. Rollback: `config 802.11a txPower ap ap-X global` (disable/enable cycle).' '_Posted by Claude Code optimizer_' | ruby misc/noc_slack.rb
   ```
7. Watch the neighbour that absorbs the load. It can hit the cap within a minute and is the next step.
8. Compare after 10 and 20 minutes: slot-1 counts, rejects per minute from the monitor, new ghost entries on the cycled radio. A radio already at 14 dBm that refills to the cap goes one more step (11 dBm).
9. While load balancing denies many re-associations, a cycle adds denials. Act only on radios at the cap and still filling.
10. Once the crowd thins, return CUSTOMIZED radios to `global` and the profile to its previous limits, one AP at a time at a break, with approval and a Slack note each. Raise it with the user before the last day ends; at Kaigi on Rails 2026 nobody did and the settings stayed.
11. Record each step (time, radio, old → new level and dBm, counts before and after) in `docs/events/<event>/power-steering.md`.

## Failed-frame ratio is not a trigger

Steer on the client cap only. A test on a high-failure radio did not lower its ratio (`docs/wifi/power-steering.md`).

## ssh_cli pitfalls on AireOS

- Check syntax with `?` in a throwaway session so a half-typed line can never execute in the main one. It takes a CLI session slot for a few seconds:
  ```bash
  hs() { timeout 30 ruby misc/ssh_cli.rb -s wlc-help "$@"; }
  h() { hs open --dialect aireos --idle-timeout 0 wlc-01.venue.rubykaigi.net >/dev/null; hs send --no-newline --timeout 5 "$1 ?"; hs close >/dev/null; }
  h 'config 802.11a txPower ap'
  ```
- The session drops now and then even with `--idle-timeout 0` (`session ... closed without a response`, about 6 times in a day). `close`, then `open` the same `-s wlc-01.venue` session, and re-check state before resuming. Without `-s` the session is named `default` and the helpers above will not find it.
- Wrap calls in `timeout 60`. A hang usually means the WLC's CLI session limit is reached; the monitor, configurator and optimizer share it.
