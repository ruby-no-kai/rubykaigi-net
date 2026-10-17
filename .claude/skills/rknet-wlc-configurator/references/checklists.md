# Checklists

## Pre-event readiness (the evening before Day 1)

Read-only on wlc-01:

```
show sysinfo                      show license summary          show redundancy summary      show time
show wlan summary                 show wlan 10 / 3 / 2          show interface summary       show interface detailed usr
show ap summary                   show wlan apgroups            show rf-profile summary      show rf-profile details <each>
show advanced 802.11a summary     show advanced 802.11a channel show advanced 802.11a txpower
show 802.11a                      show load-balancing           show band-select             show exclusionlist
show radius summary               show traplog
```

Plus: glazed config versions in S3 diffed for half-finished changes, Kea subnet size and lease time, Kea pods, BGP sessions, ping, unbound SERVFAIL, and Alertmanager silences (a catch-all `alertname=~.+` silence was found and lifted at KoR26).

Check specifically, because the KoR26 readiness check missed each of these:

- The effective client cap per radio is the RF profile's `Max Clients` (`show rf-profile details <profile> | grep 'Max Clients'`), not the WLAN or global value. KoR26 reported 200; rk-5g-hi said 100 and rejects started at 11:03.
- RF profiles override global Tx power and load-balancing settings.
- The power plan for dense halls: TPCv2 drove tra radios to 23 dBm. Decide the profile `tx-power-max` before doors (17 dBm was the KoR26 answer).
- DHCP Address Assignment Required on a WLAN served by FlexConnect APs removes IPv6-only (option 108) clients every 180 s. Test for 4 minutes with one IPv6-only laptop before doors and watch Connected For.
- Note DCA interval (every 10 minutes at KoR26; consider freezing during sessions), WLC temperature (65 °C against an 80 °C alarm), no HA, and whether backup tunnel paths are up.

## Start of Day N

1. Read-only: every change from the day before is still as intended. `show wlan 10` (Status, DHCP Address Assignment Required, load balancing), test WLANs, `show ap config general <ap>` AP Mode for a sample per group, RF profile power and LB values.
2. Static power: `show advanced 802.11a txpower` for every CUSTOMIZED radio. DCA moves radios overnight and a static level then means a different dBm (see `rknet-wlc-power-steering`).
3. List open decisions for the user (the `references/kor26.md` open items are an example).
4. Re-confirm standing approvals; do not assume they carry over.

## End of event teardown

Nobody owned teardown at KoR26. Before the last day ends, ask the user who does it and when, then list every change still in place with its rollback (see `references/kor26.md` for the KoR26 list): RF profile power limits, LB settings, WLAN switches, AP modes, static power levels, test WLANs and their AP-group mappings, BGP policy changes. Apply one item at a time with approval and a Slack note each.
