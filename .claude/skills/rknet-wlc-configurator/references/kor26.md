# Configurator record, Kaigi on Rails 2026 (JST)

## Changes

| Time | Change | Rollback |
|---|---|---|
| D1 11:05 | WLAN 10 load balancing disabled | `config wlan load-balance allow enable 10` |
| D1 11:09:31 | `config rf-profile tx-power-max 17 rk-5g-hi` (from 30) | `... tx-power-max 30 rk-5g-hi` |
| D1 11:33–11:47 | Static 14 dBm on tra-04, 13, 05, 14, 23 (then power handed to the optimizer) | `config 802.11a txPower ap <ap> global` with the radio cycle |
| D1 12:09:24 | WLAN 10 load balancing enabled (by the user) | `... allow disable 10` |
| D1 12:29–12:31 | br-01.itm transit export `[ transit-out-filter keepaway-1x accept ]` | `[ transit-out-filter accept ]` |
| D1 12:55:41 | Global LB window 20 / denial 1 (no effect: overridden by RF profiles) | previous values in `tmp/` captures |
| D1 14:11:56 | rk-5g-hi and rk-5g-med LB window 20 / denial 1 | same |
| D1 14:18:27 | ap-off-01 static level 3 (16 dBm on ch132; 10 dBm on ch40 from Day 2) | `... txPower ap ap-off-01 global` |
| D1 17:48:38 | ap-off-01 to local mode | `config ap mode flexconnect ap-off-01` |
| D1 18:19–18:20 | WLAN 14 (`24rk`) aligned with WLAN 10, DHCP-required off, mapped into rk-med | `config wlan disable 14`; `... interface-mapping delete rk-med 14` |
| D1 20:30:10–20:30:46 | WLAN 10 DHCP-required off; 23 tra/fo0 APs to local mode (back by 20:33:50) | `config wlan dhcp_server 10 0.0.0.0 required` (WLAN cycle); `config ap mode flexconnect <ap>` |
| D2 12:34:04 | `config wlan disable 14` (rk-med mapping kept) | `config wlan enable 14` |

`debug client` captures: D1 17:21, 17:54, 18:17, 18:26 (one failed on the CLI session limit).

## Still in place at Day 2 12:34

Everything above except WLAN 14, plus the optimizer's static radios (see `rknet-wlc-power-steering/references/kor26.md`). Load-balancing settings were never re-evaluated after the 180 s cause was fixed.

## Open items

1. ap-off-01 back to 16 dBm (now 10 dBm on ch40). Asked three times, no answer.
2. nat-61/62 capture for DNS stalls to `ca6d:53::c/d` (needs the user's OK).
3. Where per-client `Client Dhcp Required: True` comes from.
4. Four stale Legacy entries (Association Id 0) on lb1-01/31: clear or leave.
5. br-01.itm: prepend the /56 explicitly (check `local-as 4264600033 loops 2`) or shut itm transit.
6. WLAN 14's rk-med interface mapping.
7. Teardown owner and timing.
