# 5 GHz Tx power steering on wlc-01

In a dense session hall, RRM leaves a few radios with ~100 clients (the per-radio cap) while neighbours idle. Lowering the hot radios' Tx power shrinks their cells so clients pick neighbours. This was done by hand at Kaigi on Rails 2026 and worked; the steps are in [`../events/kor26/power-steering.md`](../events/kor26/power-steering.md). The procedure Claude sessions follow is the `rknet-wlc-power-steering` skill.

## What worked and what did not

- Static power on a radio at the cap, one step (3 dB) at a time, moved 28–46 clients to neighbours within seconds, and cap rejects stopped. A radio that refilled took one more step (14 → 11 dBm).
- The neighbour that absorbs the load can reach the cap within a minute and becomes the next step (trb-12 → trb-13, lb1-01 → lb1-31).
- An RF profile `tx-power-max` cap (17 dBm) lowered the hall's radios, but hot radios refilled within ten minutes as the crowd grew. A cap alone does not relieve them.
- Load balancing did not fix distribution (below).
- Raising max-clients was rejected: a 20 MHz radio cannot serve 200 clients well, and it does nothing for distribution.
- Failed-frame ratio is not a reason to steer. lb1-03 was cut 17 → 14 dBm as a single test: its ratio went 24.9% → 16.1% → 23.7% and untouched neighbours got worse. The ratio follows traffic volume and constant re-association (management and short-frame retries), not cell size.
- Short spikes to 90–100 often fell back on their own within minutes. Act on a radio that stays at the cap or keeps producing rejects.

## Reading load

| Signal | Where |
|---|---|
| Clients per radio | `show client summary` counted per AP for slot 1 (fresh); `bsnApIfNoOfUsers{bsnAPIfSlotId="1"}` in Prometheus (lags) |
| Cap rejections | syslog `%APF-4-ASSOCREQ_PROC_FAILED ... Maximum Client Limit Reached in AP Radio. Reject new Association.` on wlc-01; the line has no AP name |
| Power and channel per radio | `show advanced 802.11a summary` (slot column) and `show advanced 802.11a txpower` |
| Neighbours and client RSSI/SNR | `show ap auto-rf 802.11a <ap>` |

- Count slot 1 only. Per-AP totals include 2.4 GHz.
- Ghost entries (Association Id 0) show as Associated and inflate the WLC count ([`troubleshooting.md`](troubleshooting.md#5-ghost-client-entries-association-id-0)).
- SNMP lags. Right after a radio cycle Prometheus showed a 140-client "drop" while the WLC already had everyone back, and it showed 200/200 on a radio the WLC listed at 172.
- Failure ratios on idle radios, or during a burst of new joins, mean nothing. WLC channel utilization (0–1%) was not meaningful under load.

## Why RRM leaves dense radios at max power

- TPC runs TPCv2 (target RSSI -67 dBm, path-loss model). It is coverage-driven and pushed the track A radios to their hardware max (23 dBm) although each heard 8–22 neighbours at -30 to -57 dBm.
- TPCv1 instead lowers power until the third-loudest neighbour hears the AP at the threshold (-65 dBm in rk-5g-hi). With neighbours at -47 to -50 it would drop those radios to about 8 dBm, likely too far with a crowd. Consider it off-peak, possibly with a gentler threshold.
- TPC moves in steps every 600 s (`TPCv2 Target Plan: To be reached in N TPC runs`).
- AireOS load balancing only denies at association time and never moves associated clients. Enabled on WLAN 10, it denied 60–100 clients a minute without fixing distribution.
- The per-radio client cap is not load balancing. Clients rejected by the cap mostly took minutes (median about 8 min) to get on, often onto the same hot radios.

## Where settings live: RF profiles override global

Every AP is in an AP group with a 5 GHz RF profile. The profile's TPC min/max, max clients, rates and load-balancing window/denial override the global `802.11a` and `load-balancing` settings, so `config 802.11a txPower global max` has no effect.

| AP group | 5 GHz RF profile | APs (Kaigi on Rails 2026) |
|---|---|---|
| rk-hi | rk-5g-hi | tra, trb, lb1, fo0, noc |
| rk-med | rk-5g-med | lb0, int, off |

```
show wlan apgroups                    group membership and profiles
show rf-profile details rk-5g-hi      Min/Max Transmit Power, Max Clients, TPC thresholds
show advanced 802.11a txpower         Last Run, plan status, per-radio power
```

- Kaigi on Rails 2026 values: rk-5g-hi min 7 / max 30 dBm, Max Clients 100, 20 MHz, low rates disabled; rk-5g-med min -10 / max 30, Max Clients 200. rk-med radios ran 19–22 dBm, so one step there is bigger.
- The profile minimum is not honoured on XOR slot-0 radios of 2802 APs. They sit at 2 dBm.
- Channels are 20 MHz, so 36/40/44/48 do not overlap. Neighbours on adjacent channels at -50 dBm still add some interference.

## Lever 1: RF profile power limits (non-disruptive)

```
config rf-profile tx-power-max 17 rk-5g-hi      # rollback: ... tx-power-max 30 rk-5g-hi
config rf-profile tx-power-min 14 rk-5g-hi      # rollback: ... tx-power-min 7 rk-5g-hi
config advanced 802.11a txpower-update          # run TPC now without changing its mode
```

- Profile edits drop no client and take effect at the next TPC run.
- `config 802.11a txPower global once` also triggers a run, but it may switch TPC to one-shot mode. Prefer `txpower-update`.
- Some underused neighbours sat at 8 dBm under TPC and showed the worst failure ratios. Raising the profile minimum counters that.

## Lever 2: per-AP static power (drops that radio's clients)

`config 802.11a txPower ap <ap> <level>` acts on slot 1. While the radio is up it is refused with `Radio [Slot 1] is not Disabled or Customize is not enabled`, and no CLI "customize" switch was found. The working sequence:

```
config 802.11a disable <ap>
config 802.11a txPower ap <ap> <level>       # or `global` to return it to TPC
config 802.11a enable <ap>
```

- The radio is down 1–2 s. Its clients re-associate within seconds, a good share onto neighbours.
- `show ap config 802.11a <ap>` then shows `Tx Power Configuration ... CUSTOMIZED`, and TPC no longer manages that radio.
- Levels index the radio's own power table (`ap-x  CH*  L/N (X dBm) [table]` in `show advanced 802.11a txpower`). A `*` before the level means TPC manages it; no `*` means static. XOR APs list two 5 GHz radios there without a slot column, so read slot 1 from `show advanced 802.11a summary` (columns AP, MAC, slot, admin, oper, channel, level). The table depends on AP model and channel:
  - `[23/20/17/14/11/8/5/2]`: level 3 = 17 dBm, level 4 = 14 dBm
  - `[22/19/16/13/10/7/4/2]` (AP1852I and rk-med radios)
  - `[17/14/11/8/5/2]`: level 1 = 17 dBm, level 2 = 14 dBm
  - `[16/13/10/7/4/2]`
- A static setting stores the level index, not dBm. When DCA or a reboot moves the radio to another channel its dBm changes (trb-11 level 4 went from 14 to 8 dBm overnight; ap-off-01 level 3 from 16 to 10). Re-read every CUSTOMIZED radio after a channel change, an AP reboot and at the start of each day.
- Static levels survive AP reboots and mode changes, and stay after the event until someone returns them to `global`.

## Rollback

Once the crowd thins, return CUSTOMIZED radios to `global` and the profile to its previous limits, one AP at a time at a break. At Kaigi on Rails 2026 this was not done and the settings stayed on the WLC ([`../events/kor26/README.md`](../events/kor26/README.md)).
