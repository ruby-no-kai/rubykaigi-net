# Running the network during an event

How the NOC ran the venue network at Kaigi on Rails 2026 with Claude Code sessions alongside humans, and the checklists for before, during and after an event. Each event's own record goes in [`events/<event>/`](events/).

## Who does what

| Who | Does | Skill |
|---|---|---|
| NOC staff | Approve every change, physical work, teardown of an area once its sessions end | |
| monitor session | Every 20 minutes: metrics, syslog and WLC `show` commands; keeps the numbered issue board; posts status to NOC Slack; samples before and after each change; read-only | `rknet-event-monitoring` |
| configurator session | Applies changes the user approves (WLAN, AP mode, RF profiles, requested power changes, occasionally BGP policy); debug captures; posts a Slack note with rollback per change | `rknet-wlc-configurator` |
| optimizer session | Steps 5 GHz Tx power down on radios at the client cap under a standing approval; Slack note per change | `rknet-wlc-power-steering` |

- An approval counts only when the user gives it to the session that applies the change. Sessions relay findings to each other but never approvals.
- The issue board is one page per day with numbers continuing across the event. Issue titles name the symptom; `detection` is never edited; `latest` and `next` are rewritten on each update.
- The WLC allows about five CLI sessions in total. The three sessions hold one each, which leaves room for one debug capture or investigation at a time.
- Slack: one post per round in which something is new or changed (always with the board link), and one line per configuration change with its rollback.

## During the event

- Planned pulls during teardown are confirmed by the NOC team area by area; they are not incidents. Reset APs then show default asset-style names (`rk-aph…`, `rk-apm…`) on the WLC before they drop off.
- The venue empties within 30 minutes of the last session (782 → 97 clients in 20 minutes); that is not an outage.
- Prometheus lags the WLC by a minute or two around radio cycles and AP reboots; the WLC CLI decides.


## Pre-event readiness (the evening before Day 1)

Start with the previous event's "Left in place" list in `events/<event>/README.md`: the venue WLC keeps static power, AP modes and WLAN switches between events.

Read-only on wlc-01:

```
show sysinfo                      show license summary          show redundancy summary      show time
show wlan summary                 show wlan 10 / 3 / 2          show interface summary       show interface detailed usr
show ap summary                   show wlan apgroups            show rf-profile summary      show rf-profile details <each>
show advanced 802.11a summary     show advanced 802.11a channel show advanced 802.11a txpower
show 802.11a                      show load-balancing           show band-select             show exclusionlist
show radius summary               show traplog
```

Plus: glazed config versions in S3 diffed for half-finished changes, Kea subnet size and lease time, Kea pods, BGP sessions, ping, unbound SERVFAIL, and Alertmanager silences (a catch-all `alertname=~.+` silence mutes everything off-season and has to be lifted).

Check specifically; the Kaigi on Rails 2026 readiness check missed each of these:

- The effective client cap per radio is the RF profile's `Max Clients` (`show rf-profile details <profile> | grep 'Max Clients'`), not the WLAN or global value. The check reported 200; rk-5g-hi said 100 and rejects started at 11:03 on Day 1.
- RF profiles override global Tx power and load-balancing settings.
- The power plan for dense halls: TPCv2 drove tra radios to 23 dBm. Decide the profile `tx-power-max` before doors (17 dBm at Kaigi on Rails 2026; see [`wifi/power-steering.md`](wifi/power-steering.md)).
- DHCP Address Assignment Required on a WLAN served by FlexConnect APs removes IPv6-only (option 108) clients every 180 s. Test for 4 minutes with one IPv6-only laptop before doors and watch Connected For.
- Note DCA interval (every 10 minutes at Kaigi on Rails 2026; consider freezing during sessions), WLC temperature (65 °C against an 80 °C alarm), no HA, and whether backup tunnel paths are up.

## Start of Day N

1. Read-only: every change from the day before is still as intended. `show wlan 10` (Status, DHCP Address Assignment Required, load balancing), test WLANs, `show ap config general <ap>` AP Mode for a sample per group, RF profile power and LB values.
2. Static power: slot 1 of every CUSTOMIZED radio in `show advanced 802.11a summary`. DCA moves radios overnight and a static level then means a different dBm ([`wifi/power-steering.md`](wifi/power-steering.md#lever-2-per-ap-static-power-drops-that-radios-clients)).
3. List open decisions from the previous day's record (`events/<event>/`).
4. Re-confirm standing approvals; do not assume they carry over.

## End of event teardown

Two separate jobs: the physical pull, which the NOC team does area by area, and rolling back configuration, which nobody owned at Kaigi on Rails 2026. Before the last day ends, ask who rolls back and when, then list every change still in place with its rollback: RF profile power limits, LB settings, WLAN switches, AP modes, static power levels, test WLANs and their AP-group mappings, BGP policy changes. Apply one item at a time with approval and a Slack note each. Whatever stays goes into the event's "Left in place" list for the next readiness check, along with APs that were reset and need renaming from the inventory.
