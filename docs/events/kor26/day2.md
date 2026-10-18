# Kaigi on Rails 2026 Day 2 record (2026-10-17, JST)

Source: the monitor, configurator and optimizer sessions up to about 12:55. Extend this file at the wrap-up.

## Start of day

- The user resumed the sessions at about 11:30. The AWS login had expired (container-role 503) and the user logged in again. The first Alertmanager watcher failed and was re-armed after that.
- The board was not created until the third round; the user had to say "don't forget issue board". A new board was started for the day, carrying #17 and #23 with their numbers; new issues started at #26.
- The user had to ask the monitor to relay the new skills to the peers and to "resume monitor and configurator". The optimizer claimed it had loaded all five skills while having loaded three.
- ap-int-01/02 and cs-01 ge-0/0/0 and ge-1/0/0 were shut down early because Day 2 was the last day. They were closed on the board as expected.
- Too few Slack posts in the first hour: "I didn't see no updates from anyone ... did you remember the rule of slack callout?"

## Findings

- 180 s cycle stays gone with a crowd (944–976 clients): no-IPv4 median Connected For 606 s at 11:34 and 1,380 s at 11:50; syslog gaps at 170–200 s were 2.8% (12:10) and 2% (12:49). Connected For samples were noisy at lunch; the gap histogram was the steadier signal.
- Local-mode tra/fo0/off: 14 of 14 sampled clients had 1–6 global IPv6 addresses (13 without IPv4), Connected For 206–1,855 s. RA works in local mode with a crowd.
- No ghost entries (Association Id 0).
- `WifiApTooManyUsers` fired for rk-5g-med radios (ap-lb0-21 at 140; cap 200). Prometheus showed lb0-21 at 200/200 while the WLC listed 172–173.
- #26: lobby lb1 radios at lunch with 65–76 clients showed 50–80% failed frames and 90–92% channel utilization; it eased as the crowd left. No action.
- ap-trb-11's static level 4 became 8 dBm after DCA moved it from ch120 to ch44 overnight ([`power-steering.md`](power-steering.md)).
- "Trb attendee says no v4 internet": Kea, probes, NAT64 and cap rejects were clean. Likely an IPv6-only (option 108) client without CLAT (Windows, Linux, VPN or a literal IPv4 address). Workaround: the Legacy SSID. Ask for device and MAC.

## Changes

| Time | What | Who |
|---|---|---|
| 12:34:04 | `config wlan disable 14` (rk-med mapping kept); the WLC then logs "unable to find WLAN in slot to be deleted" (noise) | configurator, user request |

No power or other WLC changes through 12:55.

## Afternoon (from 12:55)

- Peak 1,023 clients at 14:29 (SNMP total 1,018). The 180 s cycle stayed gone all day: the 170–200 s bucket held 1–4% of re-association gaps, never a peak (`reassoc_gaps.rb`).
- Tx power steps by the optimizer (each held, no rejects after the step):

| Time | Radio | Change | Clients before → after |
|---|---|---|---|
| 13:56:35 | ap-trb-04 | auto 17 → static 14 dBm | 94 → 51 |
| 14:03:33 | ap-trb-12 | 14 → 11 dBm | 97 → 51 |
| 14:10:49 | ap-trb-01 | 17 → 14 dBm | 96 → 64 |
| 14:57:56 | ap-trb-02 | 17 → 14 dBm | 100 → 58 |
| 17:01:40 | ap-tra-15 | 17 → 14 dBm | 99 → 60 |

  The tra session was cancelled at about 14:30 and the crowd moved to trb, then back to tra for the last session. Prometheus over-read the radio counts by a minute or two; the WLC `slot_counts.sh` decided.
- #23 (new evidence): the WLC SISF binds a new global IPv6 address to the client MAC about 10 s after creating it (`ENTRY_CREATED` without MAC, then `ENTRY_CHANGED` with MAC). 68% of 6,984 new addresses (09:50–13:50), median 10 s, on local-mode and FlexConnect APs alike, and already on Day 1 after 17:51. First address after an association is slowest (83% slow). The WLC has `ipv6 ns-mcast-fwd disable` and its counters show about 1.2 M multicast NS dropped against 19 k forwarded; likely mechanism, not proven. A relayed handoff from a NOC member's agent gave the Mac captures (10 s from DAD to first DNS reply). Ruled out by the user: enabling NS multicast forwarding, even as a workaround (broadcast and multicast frames are discouraged on Wi-Fi to conserve airtime). Next step for a human: poll `show ipv6 neighbor-binding detailed mac <MAC>` every 1–2 s during a reassociation to see what the WLC holds during the 10 s. Not done; the 18 h/24 h neighbor-binding timers are an intentional old-macOS workaround, do not touch them untested.
- `%OSAPI-5-MUTEX_UNLOCK_FAILED` (notice) appears 5–27 times an hour on the WLC since the morning; treated as noise.
- Credentials: AWS container-role errors at 11:32, 16:04 and 16:49 (about a minute each).

## Teardown (all times JST, user-confirmed plan: lime = trb, magenta = tra, waiwai = fo0, booths = lb1; the NOC team confirms an area is done before pulling)

| Time | What |
|---|---|
| 15:53 | lb1 (9 APs) and ap-noc-01 pulled early; AP count 49 → 39. Rejects peaked at 79 in the minute 15:54. APs showed default `rk-…` names while being unplugged (a teardown-prep sign, not a fault) |
| 16:00 | es-lb1-01 uplink down |
| 16:08 | fo0 (7 APs) pulled; es-fo0-01 off 16:12 |
| 16:46–16:49 | trb (9 APs) pulled; es-trb-02 off 16:49, es-trb-01 off 16:49 |
| 18:13–18:23 | tra (16 APs) and off pulled, then lb0; es-tra-01 Gi0/12 (cast) down 18:22, es-lb0-02 off 18:22, es-lb0-01 off 18:23. Rejects 316/min at 18:12 while the leftover crowd sat on a few lobby APs |
| ~18:24 | Conference concluded; the user stopped the monitor, configurator and optimizer |

Final state at 18:24: 1 AP registered, 49 clients, only the expected `SnmpTargetDown` and `LinkStateChanged` alerts for the pulled switches.

## Left in place for the next event

- Static (CUSTOMIZED) slot-1 power on tra-04/05/13/14/15/23, trb-01/02/04/11/12/13, lb1-01/03/31 and off-01, and AP modes (tra, fo0, off local), WLAN 10 DHCP-required off, WLAN 14 disabled with its rk-med mapping, br-01.itm `keepaway-1x`. Rollbacks are in [`changes.md`](changes.md) and [`power-steering.md`](power-steering.md).
- AP names: the pulled APs that were reset report default names (`rk-aph…`, `rk-apm…`); re-name from the inventory before the next event.

## What went wrong in the monitor's own work (so the next one avoids it)

- Slack posts were too few early on, and warnings about the teardown (video crew cast ports, asking for AP names before each pull) were unneeded: the user said the NOC team confirms each area itself and told the monitor to stop worrying.
- The #23 forks were started only after the user asked "didn't you spawn investigator?". Start read-only forks as soon as an issue has a testable question.
- One board update failed on a JSON typo and a mistyped publish path; the next call fixed both. Check `update.rb` output before republishing.
