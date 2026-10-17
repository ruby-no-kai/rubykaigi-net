# Kaigi on Rails 2026 Day 1 record (2026-10-16, JST)

Source: the monitor session and the issue board. Times are JST. Use this as a worked example of what a day looks like, and as the open-items list for Day 2.

## Shape of the day

- 51 APs (AIR-AP2802I and AIR-AP1852I), all FlexConnect (group rk-venue, local switching) until 17:48. One WLC `wlc-01.venue` (AireOS 8.10.196.0). Main SSID `Kaigi on Rails 2026` (WLAN 10, WPA3-SAE, IPv6-mostly), `... Legacy` (WLAN 3), `empurple` (WLAN 2), test SSID `24rk` (WLAN 14).
- Clients 830–990 through the afternoon (track A 376 at 17:50), transit 130–510 Mbps. Venue empty within 30 minutes after 18:30: 782 clients at 18:31, 97 at 18:51, 10 at 21:26.
- Backbone stayed healthy: no tunnel drops after 09:26, tun-01.hnd CPU 40–87% (IX3100), no `Buffer is low` after 09:33, only two expected Alertmanager alerts.

## Timeline of changes and findings

| Time | What | Who | Effect |
|---|---|---|---|
| ~11:09 | 5 GHz Tx power cap on RF profile rk-5g-hi (max 17 dBm) | user-approved change | track A failed-frame ratio fell, #11 mitigated |
| 11:33–11:47 | Static 14 dBm on tra-04, 13, 05, 14, then tra-23 | configurator | load spread to neighbours; power then handed to the optimizer |
| 12:09:24 | Client load balancing enabled on WLAN 10 (WLAN restart dropped about 280 clients) | user | LB denied 60–100 clients a minute from then on; never disabled |
| 12:16 | ap-lb1-01 hit the 100-client cap | optimizer later steered | cap rejects until 15:10 |
| 12:29–12:31 | br-01.itm transit export `[ transit-out-filter keepaway-1x accept ]` | configurator, user approved | itm transit input 20–99 → 2–3 Mbps; only /31 and /32 prepended |
| 12:55:41 | Global load-balancing window 20 / denial 1 | configurator | no effect (RF profiles override) |
| 14:11:56 | RF profile load-balancing window 20, denial 1 | user-approved change | no change in re-association cadence (RF profiles had their own LB settings) |
| 14:18 | ap-off-01 static power level 3 (16 dBm) | configurator | retry ratio fell from far above normal to 0.02–0.13 |
| 14:20 | A colleague reported a delay between association and neighbour discovery | user | found the DHCP_REQD dwell (#21) |
| 14:49–14:58 | trb-12, trb-13, trb-11 static 14 dBm | optimizer, blanket approval | trb rejects stopped |
| 15:10:24 | lb1-01 static 14 dBm | optimizer | lobby rejects stopped |
| 15:22:26 | lb1-03 static 14 dBm as a failed-frame test | optimizer | ratio not improved; test stopped |
| 17:21–17:26 | `debug client` on a no-IPv4 Mac | configurator | `MN_DHCP_TIMEOUT` delete exactly 180 s after association, then disassociate, rejoin ~3 s later |
| 17:48:38 | ap-off-01 to local mode (reboot) | configurator, user approved | no 180 s drop for 11 of 11 no-IPv4 clients (258–436 s) |
| 18:19–18:20 | Test WLAN 14 aligned with WLAN 10 (WPA3, PMF, ACLs) | configurator | |
| 18:20:45 | Test WLAN 14 (`24rk`), DHCP-required off, on rk-med | configurator, user approved | FlexConnect client stayed in RUN past 600 s with option 108 honoured |
| 18:39 / 18:40 | ap-lb1-01 11 dBm, ap-lb1-31 static 14 dBm | optimizer | cap rejects: none; stale client entries appeared (#25) |
| 20:30 | WLAN 10 DHCP-required off; 23 tra/fo0 APs to local mode (back 20:33:50) | configurator, user approved in advance | 16 of 16 no-IPv4 clients sampled stayed 398 s; the ghost entries on WLAN 10 vanished |

## Issues at close (board #1–#25)

- Closed or expected: #1 tun-01.nrt IPsec output errors (09:05–09:26 only), #3 itm tunnel (not used for an East venue), #5 catch-all Alertmanager silence, #8 and #24 cast-port flaps, #10 ap-fo0-02 reboots, #12 two known alerts, #14 track A concentration, #15 and #18 radios at the client cap, #16 break-time plan, #20 ap-off-01 retries.
- Mitigated, verify on Day 2: #11 track A failed frames, #19 reconnect cycle, #21 DHCP_REQD / 180 s timeout, #25 ghost entries.
- Open: #22 lobby radios fail 18–39% of frames (ratio follows traffic volume; a 14 dBm test on lb1-03 showed no gain), #23 lossy DNS for an IPv6-only client (IPv6 resolver path), #17 tun-01.hnd CPU, #7 EAP and handshake errors (tied to #19, still seen on local-mode APs), #2 WLC radio resets on channel change.
- Noise: #4 log noise, #6 SISF fe80::1 churn, #9 cs-01 PoE voltage read.

## Open items for Day 2

Items 1, 2 and 4 were answered on Day 2 morning; see `kor26-day2.md`.

1. With a real crowd, confirm that no client is removed at 180 s on FlexConnect (lb0, lb1, trb, int, noc) and on the local-mode tra, fo0 and off APs. Use `event_snapshot.rb` and look at Connected For.
2. RA/IPv6 and DNS on the local-mode tra and fo0 APs (the original reason for FlexConnect was that the WLC stopped forwarding Router Advertisements in central switching). Only ap-off-01 had a crowd while in local mode (up to 30 clients) and looked fine.
3. DNS to `2001:df0:8500:ca6d:53::c/d` for IPv6-only clients: capture on nat-61 and nat-62 (`tun-siit`) while a client stalls. See `rknet-wifi-remediation`.
4. Legacy SSID: 4 stale entries (Association Id 0) on ap-lb1-01/31 survived two hours; clear or leave, the user decides.
5. Check that the 20:30 channel reshuffle (36–140 including DFS) did not leave neighbours on one channel; ap-off-01 showed 71% utilization and 21% retries with 20 clients on channel 40 at 10 dBm.
6. Keep the Tx power steps recorded in `rknet-wlc-power-steering`; static 14 dBm remains on tra-04/05/13/14/23, trb-11/12/13, lb1-03, lb1-31, lb1-01 at 11 dBm, ap-off-01 level 3.
