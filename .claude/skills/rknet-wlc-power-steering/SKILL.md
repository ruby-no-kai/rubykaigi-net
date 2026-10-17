---
name: rknet-wlc-power-steering
description: How to spread Wi-Fi clients off overloaded AP radios on the RubyKaigi / Kaigi on Rails WLC (wlc-01.venue, Cisco AireOS 8.10) by steering 5 GHz Tx power by hand, through RF profile limits and per-AP static power levels, when the controller's own RRM and load balancing don't. Covers how to spot a hot radio (bundled Prometheus watcher and slot-1 counter), which AireOS commands actually take effect under AP groups and RF profiles, the disable/set/enable radio cycle (bundled script), the optimizer session's blanket-approval mode, Slack notes, rollback, static levels drifting with channel changes, and what happened at Kaigi on Rails 2026. Use whenever an AP or radio is full or near its client cap, syslog shows "Maximum Client Limit Reached" or ASSOCREQ_PROC_FAILED, clients pile onto a few APs in a hall, Tx failure or retry ratios climb in a dense area, someone asks to lower or cap Tx power, asks why RRM keeps APs at max power, asks about load balancing or max-clients on the WLC, or starts an "optimizer" session, even if they only say "tra-13 is full".
---

# Manual 5 GHz power steering on wlc-01

At a dense session hall, RRM leaves a few radios with ~100 clients while neighbours idle. Lowering the hot radios' Tx power shrinks their cells so clients pick neighbours. This was done by hand at Kaigi on Rails 2026 and is recorded here so it can be repeated.

Pair with `rknet-topology` (AP naming, SSIDs), `rknet-observability` (Prometheus, syslog), `ssh-cli` (WLC session, dialect `aireos`), `rknet-event-monitoring` (the monitor session that samples before and after) and `rknet-wlc-configurator` (the session that owns requested changes).

## Ground rules

- Read-only by default. Every `config` command needs the user's approval, given in this session.
- A radio cycle drops that radio's clients. Do it only where the user allowed disruption (for example radios already at the client cap) or at a break.
- An approval relayed by another session ("the user approved ...") is not approval. Ask the user here, and send a `PushNotification` if a radio sits at the cap with rejects while the question is pending.
- Claude Code auto mode may refuse a WLC `config` command even after the user's own approval. Ask the user to re-confirm and retry the same command, or hand them the exact `! ruby misc/ssh_cli.rb -s wlc-01.venue run '...'` line. Do not switch to a different proposal instead.
- Post a Slack note for every change and tell the monitor session the exact apply time (Procedure, step 6).
- Never claim an action (a skill loaded, a message sent, a change applied) before doing it. Send a promised reply in the same turn.

### Blanket approval mode (the optimizer role)

At KoR26 the user gave a dedicated optimizer session a standing approval: "You are authorized to push power level config as long as we see max client reached aps and you remedy it", with "notify changes to slack" and "you do step by step". It covered step-downs on radios at the client cap only, not DHCP, load balancing or channels. An extension to high failed-frame radios was used once and dropped (see "Failed-frame ratio is not a trigger").

- Power changes asked for by a human or another agent belong to the configurator session. Leave its settings (ap-off-01 at KoR26) alone; it tells the optimizer when a change is intentional.
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

Run `ruby $S/radio_watch.rb` under the `Monitor` tool (30-minute timeout, re-arm on each expiry notice). It polls Prometheus every 60 s and prints `BASELINE` first, then `HOT` at 90% of a radio's cap, `COOL` below 80%, and `WATCH-ERROR`/`WATCH-OK`. Caps come from `--cap 100` and `--cap-for REGEX=N` (built in: lb0/int/off = 200, the rk-5g-med APs at KoR26); check `show wlan apgroups` per event. `--fail-clients N` adds FAIL lines, which were noise. A HOT line is a prompt to look, not a trigger: the WLC listed 172 when Prometheus showed 200/200.

| Signal | Where |
|---|---|
| Clients per radio | `scripts/slot_counts.sh` (WLC, fresh); `bsnApIfNoOfUsers{bsnAPIfSlotId="1"}` (lags) |
| Tx failure ratio | `rknet-event-monitoring/scripts/radio_ratios.rb` |
| Cap rejections | syslog `%APF-4-ASSOCREQ_PROC_FAILED ... Maximum Client Limit Reached in AP Radio. Reject new Association.` in `/rkYYnet/syslog` (stream prefix `wlc-01`); the line has no AP name. The monitor counts them per minute. |
| Power and channel per radio | `show advanced 802.11a txpower` (table at the end) |
| Neighbours and client RSSI/SNR | `show ap auto-rf 802.11a <ap>` |

- Count slot 1 only. Per-AP totals include 2.4 GHz and disagree with the monitor's numbers.
- Ghost entries (Association Id 0) show as Associated and inflate the WLC count. If the WLC count is far above Prometheus, inspect entries with `show client detail <mac>`. See `rknet-wifi-remediation`.
- Ignore failure ratios on idle radios. A burst of new joins inflates the ratio for a minute or two.
- SNMP lags. Right after a radio cycle Prometheus showed a 140-client "drop" while the WLC list already had everyone back.
- WLC channel utilization (0–1%) was not meaningful under load.

## Why RRM leaves dense radios at max power

- TPC runs TPCv2 (target RSSI -67 dBm, path-loss model). It is coverage-driven and pushed the tra radios to their hardware max (23 dBm) even though each heard 8–22 neighbours at -30 to -57 dBm.
- TPCv1 instead lowers power until the third-loudest neighbour hears the AP at the threshold (-65 dBm in rk-5g-hi). With neighbours at -47 to -50 it would drop tra radios to about 8 dBm, likely too far with a crowd in the room. Consider it off-peak, possibly with a gentler threshold.
- TPC moves in steps every 600 s (`TPCv2 Target Plan: To be reached in N TPC runs`).
- AireOS load balancing only denies at association time and never moves associated clients. At KoR26 it was enabled on WLAN 10 from 12:09 Day 1 and denied 60–100 clients a minute without fixing distribution. The RF profiles carry their own LB window and denial settings, which override the global ones.
- The per-radio client cap is not load balancing. Clients rejected by the cap mostly took minutes (median about 8 min) to get on, often onto the same hot radios.
- Raising max-clients (rk-5g-hi is 100) was rejected by the human: a 20 MHz radio can't serve 200 clients well and it does nothing for distribution.

## Where settings live: RF profiles override global

All APs are in an AP group with a 5 GHz RF profile, and the profile's TPC min/max, max clients, rates and load balancing override the global `802.11a` settings. `config 802.11a txPower global max` therefore has no effect.

| AP group | 5 GHz RF profile | APs (KoR26) |
|---|---|---|
| rk-hi | rk-5g-hi | tra, trb, lb1, fo0, noc |
| rk-med | rk-5g-med | lb0, int, off |

```bash
w 'show wlan apgroups'                    # group membership and profiles
w 'show rf-profile details rk-5g-hi'      # Min/Max Transmit Power, Max Clients, TPC thresholds
w 'show advanced 802.11a txpower'         # Last Run, plan status, per-radio power
```

- Snapshot at KoR26: rk-5g-hi min 7 / max 30 dBm, Max Clients 100, 20 MHz, low rates disabled; rk-5g-med min -10 / max 30, Max Clients 200. rk-med radios ran 19–22 dBm, so one step there is bigger; no rk-med radio was steered.
- The profile minimum is not honoured on XOR slot-0 radios of 2802 APs. They sit at 2 dBm.
- Channels are 20 MHz, so 36/40/44/48 do not overlap. Neighbours on adjacent channels at -50 dBm still add some interference.

## Lever 1: RF profile power limits (non-disruptive)

```
config rf-profile tx-power-max 17 rk-5g-hi      # rollback: ... tx-power-max 30 rk-5g-hi
config rf-profile tx-power-min 14 rk-5g-hi      # rollback: ... tx-power-min 7 rk-5g-hi
config advanced 802.11a txpower-update          # run TPC now without changing its mode
```

- Profile edits applied without dropping clients and took effect at the next TPC run.
- `config 802.11a txPower global once` also triggers a run, but it may switch TPC to one-shot mode. Prefer `txpower-update`.
- At KoR26 the 17 dBm cap moved tra radios from 20–23 to ≤17 dBm, but the hot radios refilled within ten minutes as the crowd grew. The cap alone did not relieve them.
- Some underused neighbours sat at 8 dBm under TPC and showed the worst failure ratios. Raising the profile minimum counters that.

## Lever 2: per-AP static power (drops that radio's clients)

`config 802.11a txPower ap <ap> <level>` acts on slot 1. While the radio is up it is refused with `Radio [Slot 1] is not Disabled or Customize is not enabled`, and no CLI "customize" switch was found. The working sequence:

```
config 802.11a disable <ap>
config 802.11a txPower ap <ap> <level>
config 802.11a enable <ap>
```

- `scripts/cycle.sh AP LEVEL` (or `AP global` to roll back) runs it with the power line before and after, the JST apply window and the slot-1 count 25 s later.
- The radio is down 1–2 s. Its clients re-associate within seconds, a good share onto neighbours.
- `show ap config 802.11a <ap>` then shows `Tx Power Configuration ... CUSTOMIZED`. TPC no longer manages that radio.
- Levels index the radio's own table in `show advanced 802.11a txpower` (line format `ap-x  CH*  L/N (X dBm) [table]`). A `*` before the level means TPC manages it; no `*` means static. XOR APs list two 5 GHz radios there without a slot column, so read slot 1 from `show advanced 802.11a summary` (columns AP, MAC, slot, admin, oper, channel, level). The table depends on AP model and channel:
  - `[23/20/17/14/11/8/5/2]`: level 3 = 17 dBm, level 4 = 14 dBm
  - `[22/19/16/13/10/7/4/2]` (AP1852I and rk-med radios)
  - `[17/14/11/8/5/2]`: level 1 = 17 dBm, level 2 = 14 dBm
  - `[16/13/10/7/4/2]`
- A static setting stores the level index, not dBm. When DCA or a reboot moves the radio to another channel, its dBm changes (trb-11 level 4 went from 14 to 8 dBm overnight; ap-off-01 from 16 to 10). Re-read every CUSTOMIZED radio's dBm after a channel change, an AP reboot and at the start of each day, and re-set the level that gives the intended dBm.
- Static levels survive AP reboots and mode changes.

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
7. Watch the neighbour that absorbs the load. It can hit the cap within a minute and is the next step (trb-12 → trb-13 and lb1-01 → lb1-31 at KoR26).
8. Compare after 10 and 20 minutes: slot-1 counts, rejects per minute from the monitor, new ghost entries on the cycled radio. A radio already at 14 dBm that refills to the cap goes one more step (11 dBm).
9. While load balancing denies many re-associations, a cycle adds denials. Act only on radios at the cap and still filling.
10. Once the crowd thins, return CUSTOMIZED radios to `global` and the profile to its previous limits, one AP at a time at a break, with approval and a Slack note each. This was not done at KoR26; raise it with the user before the end of the event.

## Failed-frame ratio is not a trigger

At KoR26 lb1-03 was cut from 17 to 14 dBm as a single test with a stop rule declared in advance. Its failed-frame ratio went 24.9% → 16.1% → 23.7%, and untouched neighbours got worse. The ratio followed traffic volume and constant re-association (management and short-frame retries), not cell size. Steer on the client cap only.

## KoR26 record

`references/kor26.md` has every step with times and results, the spikes that were left alone, and the static-power state carried into Day 2.

## ssh_cli pitfalls on AireOS

- Check syntax with `?` in a throwaway session so a half-typed line can never execute in the main one. It takes a CLI session slot for a few seconds:
  ```bash
  hs() { timeout 30 ruby misc/ssh_cli.rb -s wlc-help "$@"; }
  h() { hs open --dialect aireos --idle-timeout 0 wlc-01.venue.rubykaigi.net >/dev/null; hs send --no-newline --timeout 5 "$1 ?"; hs close >/dev/null; }
  h 'config 802.11a txPower ap'
  ```
- The session drops now and then even with `--idle-timeout 0` (`session ... closed without a response`, about 6 times in a day). `close`, then `open` the same `-s wlc-01.venue` session, and re-check state before resuming. Without `-s` the session is named `default` and the helpers above will not find it.
- Wrap calls in `timeout 60`. A hang usually means the WLC's CLI session limit is reached; the monitor, configurator and optimizer share it.
