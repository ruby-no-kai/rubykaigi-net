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
- ap-trb-11's static level 4 became 8 dBm after DCA moved it from ch120 to ch44 overnight (`rknet-wlc-power-steering`).
- "Trb attendee says no v4 internet": Kea, probes, NAT64 and cap rejects were clean. Likely an IPv6-only (option 108) client without CLAT (Windows, Linux, VPN or a literal IPv4 address). Workaround: the Legacy SSID. Ask for device and MAC.

## Changes

| Time | What | Who |
|---|---|---|
| 12:34:04 | `config wlan disable 14` (rk-med mapping kept); the WLC then logs "unable to find WLAN in slot to be deleted" (noise) | configurator, user request |

No power or other WLC changes through 12:55.
