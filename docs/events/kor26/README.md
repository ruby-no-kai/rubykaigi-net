# Kaigi on Rails 2026

2026-10-16/17, Tokyo (NTT East). 51 APs (AIR-AP2802I, AIR-AP1852I) on one AireOS WLC, peak 1,023 Wi-Fi clients (Day 2 14:29 JST). Run by the NOC with three Claude Code sessions (monitor, configurator, optimizer; see [`../../event-operations.md`](../../event-operations.md)). Board issues #1–#30.

| File | Content |
|---|---|
| [`day1.md`](day1.md) | Day 1: shape of the day, change and finding timeline, issues at close, open items for Day 2 |
| [`day2.md`](day2.md) | Day 2: findings, afternoon power steps, teardown timeline, what went wrong in the monitor's own work |
| [`changes.md`](changes.md) | Every configuration change by the configurator with its rollback, and open items |
| [`power-steering.md`](power-steering.md) | Every Tx power step with results, and the static power state on Day 2 |
| [`batch-2030.txt`](batch-2030.txt) | The pre-approved Day 1 20:30 change set (input to `.claude/skills/rknet-wlc-configurator/scripts/wlc_batch.sh`) |

Lessons that apply to any event are in [`../../wifi/`](../../wifi/) and [`../../event-operations.md`](../../event-operations.md).

## Venue wiring

From LLDP on 2026-10-16:

| cs-01 port | Device | Downstream |
|---|---|---|
| `ge-0/0/8` (ae0) | es-tra-01 Gi0/13 | es-tra-02 via Gi0/15 |
| `ge-1/0/8` (ae1) | es-trb-01 Gi0/13 | es-trb-02 via Gi0/15 |
| `ge-0/0/7` (ae2) | es-lb0-01 Gi0/9 | |
| `ge-1/0/7` (ae3) | es-lb0-02 Gi0/13 | |
| `ge-0/0/9` (ae4) | es-lb1-01 Gi0/9 | |
| `ge-1/0/9` (ae5) | es-fo0-01 Gi0/13 | |
| `ge-0/0/0–4`, `ge-1/0/0–4` | ap-int-01/02, ap-noc-01, ap-lb0-21, ap-lb1-01/02/03/21/31/32 directly | |
| `ge-0/0/20–21`, `ge-1/0/20–21` | nat-61, nat-62 (me0, enp2s0) | |

Not deployed: `wire-01..04`, `as-01`, `show-01`, `tun-03`. cs-01 ports tagged `#rk26` were unused. cloudprober-01/02.venue were connected from Day 1.

## Left in place for the next event

Configuration still on the WLC and routers after the event (2026-10-17 18:24 JST). Roll back or keep each item at the next readiness check:

- Static (CUSTOMIZED) slot-1 Tx power on tra-04/05/13/14/15/23, trb-01/02/04/11/12/13, lb1-01/03/31 and off-01 ([`power-steering.md`](power-steering.md), [`day2.md`](day2.md#afternoon-from-1255)). Rollback: `config 802.11a txPower ap <ap> global` with the radio cycle.
- RF profile rk-5g-hi `tx-power-max 17` (was 30); RF profile LB window 20 / denial 1 on rk-5g-hi and rk-5g-med; global LB window 20 / denial 1.
- WLAN 10: DHCP Address Assignment Required off; client load balancing on.
- tra, fo0 and ap-off-01 in local mode; the other APs FlexConnect.
- WLAN 14 (`24rk`) disabled, still mapped into AP group rk-med.
- br-01.itm transit export `[ transit-out-filter keepaway-1x accept ]`.
- APs reset during teardown report default names (`rk-aph…`, `rk-apm…`); rename them from the inventory.

Rollback commands for each are in [`changes.md`](changes.md).

## Open questions

- #23: the WLC's SISF binds a new global IPv6 address to the client MAC about 10 s after creating it (68% of new addresses, median 10 s). Suspected `ipv6 ns-mcast-fwd disable`; not proven. Enabling NS multicast forwarding is ruled out (airtime); the untested next step is polling `show ipv6 neighbor-binding detailed mac <MAC>` every 1–2 s during a reassociation ([`day2.md`](day2.md)).
- DNS stalls to `2001:df0:8500:ca6d:53::c/d` for IPv6-only clients ([`../../wifi/troubleshooting.md`](../../wifi/troubleshooting.md#6-dns-for-ipv6-only-clients-unresolved)).
- Source of per-client `Client Dhcp Required: True` on a WLAN with the setting off.
- The other open items in [`changes.md`](changes.md#open-items).
