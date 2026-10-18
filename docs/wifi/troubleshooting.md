# Wi-Fi troubleshooting on wlc-01

Problems found and fixed on the venue WLC (wlc-01.venue, AireOS 8.10), with the evidence for each. Everything here was first seen at Kaigi on Rails 2026 (51 APs, all FlexConnect at first); times are that event's, in JST. Items marked unverified are not established. The event's own timeline is in [`../events/kor26/`](../events/kor26/).

Every `config` change here drops clients somewhere (a radio, WLAN or AP-mode cycle). Note the apply time so before/after samples can be compared.

## 1. Clients re-associate about every 182 s

Symptom: clients without an IPv4 address (everyone who accepts DHCP option 108) were removed and rejoined every ~182 s. About 82–89% of sampled no-IPv4 clients had Connected For under 190 s; clients with IPv4 (for example the same Mac on the Legacy SSID) stayed 600+ s. Syslog showed `USE_DEFAULT_CIPHER_SUITE` and `MOBILESTATION_NOT_FOUND` every ~182 s per client.

Cause (established by `debug client` on a no-IPv4 Mac): the AP sends `Received DELETE mobile, reasonCode MN_DHCP_TIMEOUT, deleteReason 4 from AP` exactly 180 s after association; the WLC then disassociates and the client rejoins after ~3 s. The WLC logs "DHCP required on AP … for this client" at association.

What it was not: load balancing (RF profiles override the global LB settings; matched-window comparison before and after showed no change), RF conditions, RADIUS (none used), the rejoin rate of clients with IPv4.

What stops it:

| Condition | Result |
|---|---|
| FlexConnect AP, WLAN with DHCP Address Assignment Required enabled | removal at 180 s (the bug) |
| Local-mode AP (ap-off-01, 17:48), same WLAN | no removal; 11 of 11 no-IPv4 clients stayed 258–436 s |
| FlexConnect AP, WLAN 14 with DHCP required disabled | client stayed past 600 s; it showed IP `192.0.0.2` (the AP learned the CLAT address) |
| WLAN 10 with DHCP required disabled (20:30), all APs | 16 of 16 no-IPv4 clients stayed 398 s; one FlexConnect IPv6-only client 431 s |

Caveat: the WLAN 14 client had a learned CLAT IPv4 address. The 20:30 WLAN 10 sample included an IPv6-only FlexConnect client without one (ap-lb1-03), but the venue was nearly empty. Re-verify with a crowd.

Rollback for WLAN 10: `config wlan disable 10; config wlan dhcp_server 10 0.0.0.0 required; config wlan enable 10` (the enable drops the SSID for a few seconds).

## 2. DHCP Address Assignment Required, option 82 and option 108

- Kea (`k8s/dhcp/config/class_main_ssid.libsonnet`): class `main_ssid`, `only-if-required`, test `not match('.*Legacy', split(relay4[2].hex, ':', 2))`, option `v6-only-preferred` (108) 1800. So a main-SSID client gets option 108 whether option 82 is present or absent; only the Legacy SSID is excluded, by its remote-id ending in `Legacy`.
- The WLC adds option 82 (`apname:ssid`, global format, per-interface option 82 on usr and life) through its DHCP proxy. These settings are separate from "DHCP Address Assignment Required".
- The first proposal to turn DHCP-required off on WLAN 10 was rejected because it was believed option 82 and 108 would break. The class logic above shows 108 does not depend on option 82. The user then approved the change (20:30).
- A 108-capable client never sends DHCPREQUEST, so Kea logs no lease line for it. Not seeing one is not evidence of failure.
- Legacy (WLAN 3) keeps DHCP required; it needs option 82 to reach the non-108 branch. Keep the `Legacy` suffix when renaming SSIDs.
- Test pattern that worked: a mirror WLAN (WLAN 14, SSID `24rk`) on the same interface with only the one setting changed, mapped into one AP group (`config wlan apgroup interface-mapping add rk-med 14 usr`). Rollback `config wlan disable 14` and `config wlan apgroup interface-mapping delete rk-med 14`. Note that a PSK WLAN refuses a session timeout of 86400 (max 65535); WLAN 14 clients got 1800 s while WLAN 10 shows 0, which confounds sessions longer than 30 minutes.
- `Client Dhcp Required: True` still shows on a client of a WLAN with the setting disabled. The flag does not drive the AP timer.

## 3. FlexConnect versus local mode

- All 51 APs started FlexConnect (group rk-venue, local switching, central DHCP proxy). The reason was an earlier, unresolved problem: in central switching the WLC stopped forwarding Router Advertisements to clients.
- Local mode on ap-off-01 (17:48) and, at 20:30, on 23 tra and fo0 APs. `config ap mode local <ap>` (rollback `config ap mode flexconnect <ap>`) reboots the AP for 3–5 minutes (all 23 were back in about 3 minutes).
- With ap-off-01 in local mode, up to 30 clients over about 3 hours. They kept 2–3 global IPv6 addresses, fresh RAs reached them (SISF learned new addresses), and the user reported no RA/NS problem. The RA problem has not been reproduced in local mode so far. On Day 2 with a crowd, 14 of 14 sampled clients on local-mode tra, fo0 and off APs held 1–6 global IPv6 addresses and none showed the 180 s cycle.
- In local mode the Flex ACLs (`rk-nodisco`, `rk-nodisco6`: mDNS, LLMNR, SSDP, WS-Discovery, NetBIOS) no longer apply on those APs.
- After a mode change the AP rejoins with DCA-chosen channels. Static power levels survive, but a level maps to different dBm per channel (level 3 was 16 dBm on channel 132 and 10 dBm on channel 40). The 20:30 reboot spread tra and fo0 channels over 36–140 including DFS.
- Check afterwards: `show ap config general <ap>` (mode, group, LWAPP uptime), `show ap summary` count, Alertmanager `LinkStateChanged` on the `air` ports (the reboot bounces them). An alert that resolves may have timed out with the link still down, so confirm with `show interfaces terse` or `show interfaces status`.

## 4. Load balancing

- WLAN 10 load balancing was disabled until the user enabled it at 12:09:24 Day 1 (a WLAN restart that dropped about 280 clients). It stayed enabled through Day 2. The RF profiles (rk-5g-hi, rk-5g-med) carry their own LB window and denial count and override the global values (`config load-balancing ...` at 12:55:41 had no effect).
- A relaxed setting (window 20, denial 1, applied 14:11:56) changed nothing in the re-association cadence. The LB denied 65–85 clients per minute throughout and about 23,800 in total. It only denies at association time and never moves associated clients.
- Distribution was fixed by Tx power steering on hot radios ([`power-steering.md`](power-steering.md)), not by LB.

## 5. Ghost client entries (Association Id 0)

- At 20:26 `show client summary` listed 105 clients while the per-radio counts summed to 29. 39 entries on ap-lb1-31 and 38 on ap-lb1-01 had Association Id 0 and Connected For about 6,500 s, started 18:34–18:40, the time of static power changes on those two radios (18:39:26 and 18:40:37).
- Hypothesis (unverified): a radio reset left WLC entries behind.
- Disabling WLAN 10 at 20:30 removed the WLAN 10 entries (client count 105 to 15). Four entries on the untouched Legacy WLAN stayed for 2+ hours, so they do not age out quickly.
- They inflate the WLC client count and the SSID gauge, and they look like long-lived no-IPv4 clients, which hides the 180 s cadence in a sample. Skip Association Id 0 when sampling (`.claude/skills/rknet-event-monitoring/scripts/event_snapshot.rb` does).
- Clearing them (`config client deauthenticate <mac>` or a WLAN cycle) is a state change; ask the user.
- Real clients on a local-mode AP had Association Ids (1, 18, 33, …); on the affected FlexConnect AP they were 0.

## 6. DNS for IPv6-only clients (unresolved)

- RA on cs-01 `irb.400`: RDNSS `2001:df0:8500:ca6d:53::c` and `::d`, lifetime 1800 s; DNSSL `venue.rubykaigi.net` 3600 s; PREF64 `2001:df0:8500:ca64:a9:8200::/96` 1800 s; prefix valid 3600 s, preferred 1800 s; default RA interval (Junos 600 s). cs-01 received about 194 router solicitations and sent about 18 RAs per minute while the reconnect cycle was running.
- The user's IPv6-only Mac on `24rk` (AP ap-lb0-11) saw about 20 queries to `ca6d:53::c/d` with no reply, while `dig @192.50.220.164` via NAT64 worked in 14 ms. Neighbour state on cs-01 was fine (REACHABLE for the source address at 18:32:24; the entry appeared ~18:32:22 and was missing at 18:31:59).
- cs-01 reaches `2001:df0:8500:ca6d::/64` only by BGP from AS65026, ECMP to nat-61 and nat-62 (SIIT, `tun-siit`), which translate to the IPv4 anycast resolvers. nat-61/62 looked healthy (CPU ~7%, no softnet drops, conntrack 13.7k and 8.9k). The unbound pods and cloudprober probes are healthy (SERVFAIL 0.01%, about 1,000 q/s), but those probes hit pod IPs and do not test the SIIT path.
- ICMP from cs-01 to the resolvers is dropped for both IPv4 and IPv6 (100% loss), so ping proves nothing.
- Next step: capture on nat-61 and nat-62 (`tun-siit` and the venue-side port, destination `ca6d:53::d`) while the Mac stalls; ECMP can hide one bad box. Ask the user for a test from a native IPv6 source with `dig +short @2001:df0:8500:ca6d:53::c` per source address.

## 7. Debug sessions and the CLI limits

- `.claude/skills/rknet-wlc-configurator/scripts/wlc_debug_client.sh MAC 300` runs a capture in its own CLI session and turns debug off afterwards.
- `debug client <mac>` for 4–5 minutes covers one 180 s cycle. A second `debug client` replaces the first. The WLC closes a debug session when a WLAN is enabled. `debug disable-all` afterwards.
- The WLC allows few concurrent CLI sessions; a debug session in the configurator's session plus the monitor's session reached the limit once. Do not open extra sessions.
- Read-only cs-01 commands used: `show ipv6 router-advertisement`, `show configuration protocols router-advertisement | display set`, `show configuration groups ipv6ra-common | display set`, `show ipv6 neighbors | match <mac>`, `show route <addr>`.

## 8. "No IPv4 internet" reports

- Seen on Day 2 from track B. Kea, cloudprober, NAT64 and cap rejects were clean.
- Likely cause: the client accepted option 108 (IPv6-only) but has no CLAT (Windows, Linux, some VPNs) or the app uses a literal IPv4 address. macOS and iOS run CLAT and reach IPv4 through `192.0.0.2`.
- Ask for device, OS, SSID and MAC, then check `show client detail <mac>` and `.claude/skills/rknet-event-monitoring/scripts/mac_cadence.rb <mac>`. Workaround: the Legacy SSID, which never sends option 108.
