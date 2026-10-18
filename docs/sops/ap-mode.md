# SOP: converting APs between local and FlexConnect mode

| Mode | Client traffic | Notes |
|---|---|---|
| Local | tunnelled to the WLC (central switching) | Flex ACLs (`rk-nodisco`, `rk-nodisco6`) do not apply; all traffic crosses the 3504 |
| FlexConnect | switched at the AP onto VLAN 400/300 (local switching, central DHCP) | Kea needs the WLC's option 82 remote-id, so DHCP stays central; the FlexConnect AP removes clients without a DHCPv4 lease every 180 s when the WLAN has DHCP Address Assignment Required ([`../wifi/troubleshooting.md`](../wifi/troubleshooting.md#1-clients-re-associate-about-every-182-s)) |

Why each mode was chosen at Kaigi on Rails 2026 is in [`../wifi/troubleshooting.md`](../wifi/troubleshooting.md#3-flexconnect-versus-local-mode).

## Input

A list of AP names or areas (for example "tra and fo0") and the target mode.

## One-time FlexConnect setup

Needed once per controller configuration before any AP goes FlexConnect; check `show flexconnect group detail rk-venue` and skip what is already there. This was set up on 2026-10-16 and saved with `save config` on 2026-10-17.

1. Switch ports for APs must trunk VLANs 200 (native), 300 and 400; check cs-01 `iface-switchport-air` and every es-* AP port.
2. Discovery ACLs: `config flexconnect acl create rk-nodisco`, deny UDP 5353, 5355, 1900, 3702, 137–138 and permit the rest (`acl rule add|protocol|destination port range|action`), then `config flexconnect acl apply rk-nodisco`; the same as `config flexconnect ipv6 acl ... rk-nodisco6` without NetBIOS.
3. Group: `config flexconnect group rk-venue add`, `... vlan enable`, `... vlan native 200`, `... vlan override-ap enable` (asks `Are you sure ? (y/n)`; an unanswered prompt cancels it).
4. Per WLAN (1, 2, 3, 10, 14), local switching first: `config wlan flexconnect local-switching <W> enable` (an enabled WLAN must be disabled around it, which drops that SSID for a few seconds), then `config flexconnect group rk-venue central-dhcp <W> enable override dns disable nat-pat disable`. Central DHCP before local switching fails with `Wlan Id <W> is centrally switched`.
5. ACLs per WLAN (WLAN disabled): `config wlan flexconnect post-auth acl rk-nodisco <W>` and `... post-auth ipv6 acl rk-nodisco6 <W>`; the ACL name comes before the WLAN id.

## Converting

1. Save `show ap summary` into `tmp/` and, per AP, `show ap config general <ap>` (AP Mode, AP group, FlexConnect group) as the before state.
2. Generate the batch:

   ```
   ruby .claude/skills/rknet-wlc-configurator/scripts/ap_batch.rb mode tmp/apsum-....txt local '^ap-(tra|fo0)-' > tmp/ap-mode.txt
   ```

   For `flexconnect` it adds `config flexconnect group rk-venue ap add <Ethernet MAC>` after each mode change. Adding before the mode change is refused (`Ap is not in flexconnect mode`), and an AP converted without it lands in `default-flex-group`.
3. Pilot one AP when the controller or the target mode is new for this event.
4. Apply with `.claude/skills/rknet-wlc-configurator/scripts/wlc_batch.sh tmp/ap-mode.txt`. Every mode change asks `Changing the AP's mode will cause the AP to reboot. Are you sure you want to continue? (y/n)`; `!` lines answer it. An unanswered prompt swallows the next command (only 8 of 51 converted on a first loop), so never loop plain `run` calls.
5. Wait for rejoin: `.claude/skills/rknet-wlc-configurator/scripts/ap_rejoin_wait.sh '^ap-(tra|fo0)-' 23`.
6. Verify: `show ap config general <ap>` AP Mode for every AP; for FlexConnect also `show flexconnect group summary` (count in rk-venue) and a client's `show client detail` (`FlexConnect Data Switching Local`, `FlexConnect Dhcp Status Central`, VLAN 400).

## Timing and impact

- FlexConnect → local reboots the AP: 23 APs converted in 35 s and all were back 3.5 minutes later (ap-off-01 alone: about 5 minutes). Their clients are without Wi-Fi meanwhile, so convert at a break or after hours.
- Local → FlexConnect asks the same reboot question, but an AP converted on 2026-10-16 kept its original join time, so it may not reboot. Plan for a reboot anyway.
- After a reboot DCA picks new channels (the 2026 batch spread over 36–140 including DFS). Static Tx power levels survive but map to a different dBm on the new channel; re-check them ([`../wifi/power-steering.md`](../wifi/power-steering.md#lever-2-per-ap-static-power-drops-that-radios-clients)).
- AP-port link alerts fire during the reboot and clear within minutes.
- Rollback is the opposite conversion, with another reboot.
