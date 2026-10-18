---
name: rknet-wifi-remediation
description: Playbook of Wi-Fi problems found and fixed on the RubyKaigi / Kaigi on Rails WLC (wlc-01.venue, AireOS 8.10, FlexConnect APs) with the evidence for each: clients that re-associate every ~182 s because the FlexConnect AP deletes clients that have no DHCPv4 lease (MN_DHCP_TIMEOUT), DHCP Address Assignment Required, how Kea sends IPv6-mostly option 108 and what option 82 does, FlexConnect versus local mode, RF-profile load balancing, ghost client entries with Association Id 0, and DNS to the 2001:df0:8500:ca6d:53::c/d resolver addresses through the nat-61/62 SIIT boxes. Use when clients drop and rejoin on a fixed cadence, new clients wait in DHCP_REQD, IPv6-only or CLAT clients lose connectivity, a Mac or iPhone shows "no IPv4", DNS stalls for IPv6-only clients, someone asks whether to change DHCP-required, AP mode or load balancing, or the WLC client count disagrees with per-radio counts.
---

# Wi-Fi remediation on wlc-01

The playbook lives in `docs/wifi/troubleshooting.md` so NOC staff can read it too. Read the section that matches the symptom before proposing anything:

| Symptom | Section |
|---|---|
| Clients rejoin about every 182 s, `MN_DHCP_TIMEOUT`, new clients stuck in DHCP_REQD | 1, 2 |
| Questions about DHCP-required, option 82 or option 108 | 2 |
| FlexConnect or local mode, RA delivery, AP mode changes | 3 |
| Load balancing denials or distribution | 4 (and `rknet-wlc-power-steering`) |
| WLC client count far above the per-radio sum | 5 |
| DNS stalls for IPv6-only clients | 6 |
| `debug client` and CLI session limits | 7 |
| "No IPv4 internet" from one attendee | 8 |

Related docs: `docs/wifi/aireos.md` (AireOS command behaviour), `docs/wifi/client-tests.md` (commands to give a Mac user), `docs/topology.md`.

- Read-only by default. Every `config` command needs the user's approval for that change in this session. Changes during an event go through the configurator session (`rknet-wlc-configurator`).
- Say what was applied and when, so the monitor (`rknet-event-monitoring`) can take before and after samples.
- When a new problem is understood, add it to `docs/wifi/troubleshooting.md` with its evidence; put the event's timeline in `docs/events/<event>/`.
