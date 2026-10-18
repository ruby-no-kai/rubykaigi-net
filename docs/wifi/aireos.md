# AireOS and Junos notes

Command behaviour on wlc-01 (AireOS 8.10) and the Junos routers learned while changing them during Kaigi on Rails 2026.

## Prompts and states

- `config ap mode local <ap>` (and `flexconnect`) asks `Are you sure you want to continue? (y/n)`. Use `send` then `send 'y'`, not `run` (`wlc_batch.sh` `!` lines). The first prompt in a batch timed out in ssh_cli but the `y` still applied; confirm by watching the AP leave `show ap summary`. The AP reboots for 3–5 minutes.
- DHCP-required and several other WLAN settings are refused while the WLAN is enabled (`Request failed - WLAN in the enabled state`). `config wlan disable N` / change / `config wlan enable N` drops the SSID for a few seconds and ends any running `debug client`.
- `config wlan dhcp_server 10 0.0.0.0` prints `Note: DHCP server override is applicable only to the default AP group.` It still turned DHCP Address Assignment Required off for the WLAN (verified with `show wlan 10`). Re-enable with `config wlan dhcp_server 10 0.0.0.0 required`.
- `Client Dhcp Required: True` still shows on clients of a WLAN with DHCP-required disabled. Its source was not found (an exploration of `show flexconnect group detail rk-venue`, `show interface detailed usr`, `show dhcp opt-82` hung on the session limit).

## Load balancing

- Per-WLAN switch: `config wlan load-balance allow enable|disable 10` (needs the WLAN disabled). Toggling it restarts the WLAN (about 280 clients dropped at Kaigi on Rails 2026).
- Parameters: global `config load-balancing window|denial ...` has no effect on APs in RF-profile groups. Per profile: `config rf-profile load-balancing window <0-20> <profile>` and `... denial <1-10> <profile>`. Window 20 is the most lenient (a smaller window denies more).
- Load balancing only denies at association and never moves associated clients. Only disabling it on the WLAN stops the denials.

## Aligning a test WLAN with WLAN 10

What made WLAN 14 (`24rk`) match WLAN 10 except for the setting under test, after the user asked "can't we align all other configurations except ssid including wpa3?":

```
config wlan security wpa wpa3 enable 14
config wlan security wpa akm pmf psk enable 14
config wlan security wpa akm sae enable 14
config wlan security pmf optional 14
config wlan radius_server auth add 14 1
config wlan radius_server auth add 14 2
config wlan radius_server acct disable 14
config wlan radio 14 802.11a
config wlan flexconnect post-auth acl rk-nodisco 14
config wlan flexconnect post-auth ipv6 acl rk-nodisco6 14
config wlan apgroup interface-mapping add rk-med 14 usr
config wlan enable 14
```

- The PSK is set by the user, never through Claude.
- A PSK WLAN refuses a session timeout of 86400 (max 65535). WLAN 14 got 1800 s while WLAN 10 shows 0, a difference for sessions over 30 minutes.
- Adding a WLAN to an AP group's interface mapping reset no AP and dropped no client.
- Rollback: `config wlan disable 14`, then `config wlan apgroup interface-mapping delete rk-med 14`.

## RA-related WLC state (Kaigi on Rails 2026)

RA throttling disabled, RA Guard on AP enabled, global multicast disabled, AP multicast mode unicast. Commands: `show ipv6 summary`, `show ipv6 ra-guard ap summary`, `show network multicast mgid summary`.

## Junos change with a confirm window (br-01.itm transit export)

1. Compare the policy across br-01.{itm,hnd,nrt} from `s3://rk-infra/glazed/redacted/`.
2. `configure`, then `delete protocols bgp group transit export` before `set protocols bgp group transit export [ transit-out-filter keepaway-1x accept ]`. A plain `set` appends to the existing list.
3. `show | compare`, `commit check`.
4. `commit confirmed 5`. Claude Code's auto mode refused it, so a human ran it.
5. Verify within the window: `run show route advertising-protocol bgp <peer>` and transit Mbps (`sum(irate(ifHCInOctets{instance=~"br-.+",ifAlias=~"^Transit:.+"}[2m]) * 8)`), then `commit` and `exit`.

- `keepaway-1x` uses `as-path-expand last-as`, which does nothing on locally originated routes. Only the /31 and /32 got prepended; the /29 aggregates and `2001:df0:8500:ca00::/56` did not. itm transit input still fell from 20–99 to 2–3 Mbps.
- Rollback: `set protocols bgp group transit export [ transit-out-filter accept ]` (after the same `delete`).
- Lowering local preference on one PoP to shed load disables ECMP entirely (user: "lowering preference disables load distribution isn't it?").
