# rknet topology

The same infrastructure serves RubyKaigi and Kaigi on Rails. Event-specific config is tagged `#rkYY` (RubyKaigi) or `#korYY` (Kaigi on Rails). The venue part is rebuilt for every event, so the concrete venue values here are a snapshot (last taken at Kaigi on Rails 2026, 2026-10). Re-check them against the sources below and update this file when they change. Per-event wiring and state live under [`events/`](events/).

The authoritative topology diagram is drawn over the venue floor plan and kept privately in the NOC Google Drive.

## Sources of truth

| What | Where |
|---|---|
| Addressing plan: every router interface, loopback and /31 link, per site | `hosts.txt` (tab-separated: site, network, cidr, ip, host, iface, mac, year). `gen-hosts.rb` turns it into `<host>.<site>.rubykaigi.net` DNS records. |
| Device inventory that gets backed up | `glazed/glazed.jsonnet` |
| Running configs (redacted) | `s3://rk-infra/glazed/redacted/<host>.<site>` |
| DHCP subnets, pools, options | `k8s/dhcp/config/subnet_*.libsonnet`, `consts.libsonnet`, `class_*.libsonnet` |
| What is physically plugged where | LLDP: `show lldp neighbors` on cs-01 (Junos) and es-* (IOS). The WLC does not appear in LLDP. |

CDP on es-* is misleading on uplink ports. CDP frames are flooded through cs-01, so every switch "sees" the WLC and other switches' APs on its uplink. Use LLDP.

## Interface descriptions

Format: `Role: <peer-port>@<peer-host>[.site] [via <port>@<l2-hop>] [{attr}] [[kind]] [#event]`. The peer port is written in the peer's own syntax (`ge-0/0/5.10`, `Gi1.10`, `Tun10.0`, `Po1`).

- **Roles:**
  - `Upstream`: toward the Internet.
  - `Downstream`: toward users. On cs-01, `irb.N` is described as `Downstream: <vlan>`.
  - `Core`: same-tier links (br↔br, er↔er, br↔PoP tun `Gi2`, the AWS VPN).
  - `Backbone`: cs-01's L2 trunks to es-* and the WLC.
  - `Access`: a single-VLAN or non-transit attachment, such as `Access: air` or er↔tun `.1`.
  - `Transit`: AS59128 KMC.
  - `Uplink`: the hnd datacenter handoff.
  - `Circuit`: an NGN or PPPoE line.
  - Also `Management`, `Function` (`{vrf=awsnat}`), `Recon`/`Scout` (recon-01 tunnels) and `TMP`.
- The tun boxes act as transparent L2 bridges, so they label the whole venue path `Downstream`, including their tunnels toward the PoPs.
- **Braces and brackets:**
  - `{aeN}` on a Junos member port names the local bundle.
  - `{private}`, `{public}`, `{vrf=..}`, `{scout-a}` and `{VACANT}` are attributes.
  - `[etherip-ipsec]`, `[etherip]`, `[ipsec]`, `[v4public]`, `[nat44-inside]` and `[1G]` give the link kind.
- **Tags and placeholders:**
  - `#rk26` / `#kor26` mark ports cabled for that event.
  - `TBD_*`, `VACANT` and `tmp` are placeholders.
  - A trailing `;` on cs-01 is noise.
- **NEC IX bindings:** IX tunnels add bindings after a comma, as in `Downstream: ge-0/0/5.10@er-01.venue, Tun10 [etherip-ipsec]`. `(Gi2.10)` names the far tun's bridged sub-interface. IX BGP neighbors carry a bare `<IfName> <host>`.
- `[~REDACTED:...:note=hnd-uplink~]` is glazed masking the datacenter provider, not an error.
- **NGN prefix masking:** the `redact-pattern/*` notes (`nrt-ngnx`, `nrt-ngnn`, `hnd-*`, `itm-ngn`) mask the PoP NGN prefixes and need updating when a PoP circuit changes. Venue NGN prefixes (`2408:210:…`) are not sensitive and intentionally left unmasked.
- **Other vendors:** IOS es-* only give the VLAN name (`air`, `cast`), and their uplinks have no description. AireOS has none. Junos BGP neighbors carry descriptions too, often with a different role from the interface.
- **Parsed by Grafana, so keep these exact when editing:**
  - `^Transit:` and `^Uplink:` on br-*
  - `Core:.*vpn-` on tun-*
  - the last `[...]` and the `tun-NN.site` on venue tun `Tunnel*.0`
  - the exact cs-01 strings `Upstream: enp2s0@nat-6N.venue`, `Upstream: ge-0/0/0@er-0N.venue` and `Upstream: Gi1.0@nat-4N.venue` (IPv6-mostly dashboard)
- **Descriptions are hand-maintained and often stale, especially right after day-0 setup.** Common causes:
  - -02 boxes copied from -01 without fixing names (er-02 still names nat-41, tun-01.venue and itself)
  - template defaults (`misc/ix_tun.rb` hardcodes `Gi2.x0`; cs-01 trunks say `Gi14@es-*`/`Po1` while es-* use Gi0/9 or Gi0/13 and Po1 or Po2)

  Before relying on the peer side of a description, check it against LLDP, the peer's own config or `hosts.txt`.

## Sites

| Site | Role | Devices |
|---|---|---|
| `hnd`, `nrt` (NTT East), `itm` (NTT West) | Backbone PoPs (datacenters) | `br-01` (Junos border router), `tun-01` (NEC IX, terminates NGN tunnels and mostly bridges L2) |
| `transit` | Upstream transit from AS59128, run by KMC (many KMC sysadmins are on the NOC team) | `br-01` peers with `*-kmc` routers |
| `apne1` | AWS ap-northeast-1 VPC `10.33.128.0/18` | EKS `rknet`, Kea, RADIUS, Prometheus, syslog, `wire-99`, `resolver` |
| `venue` | Conference venue, rebuilt per event | see below |
| `hot` | "Hot stage": an office in Tokyo where APs are set up before shipping to the host town. Rarely used. | `gw-01`, `tun-01`, subnets `20xxx` (`10.33.120–124.0/24`, `subnet_*2.libsonnet`) and `933` (`hot_usr`, `10.33.33.0/24`) |
| `tkyk` | Lab. Alerts for it are silenced. | `er-99`, `cs-99`, `nat-49`, `nat-69`, `wlc-90/99`, ... |

Also at nrt: `recon-01` ("scout" tunnels for remote recon of a venue, `Tunnel7` on the venue tun boxes) and `test-cs-01`.

Loopbacks are in `10.33.0.0/24` and `2001:df0:8500:ca00::/64`. Point-to-point links are in `10.33.22.0/24` and `2001:df0:8500:ca22::/...`. The v6 link `ca22:<N>::/124` matches the v4 /31 `10.33.22.<N>`. The public PA space is `192.50.220.152/29`–`.168/29`.

### Regional constraint (NTT East/West)

A FLET'S NGN circuit without a VNE cannot reach beyond its own regional network, and that includes the Internet. So:

- For a venue in NTT East (Tokyo, for example Kaigi on Rails), only the hnd and nrt tunnels can come up. **No active tunnel from itm to the venue is expected**, and `.30/.31` BGP being down is normal.
- For an East venue, traffic received at itm has to be carried to hnd/nrt, so itm transit should not attract it. Check br-01.itm's transit export at the start of each East event; an equal-preference export pulls traffic in at itm. `keepaway-1x` (`as-path-expand last-as`) skips locally originated routes, so it prepends only the /31 and /32, not the /29 aggregates or `2001:df0:8500:ca00::/56` ([Kaigi on Rails 2026](events/kor26/changes.md)). For a venue in NTT West the roles flip.

### AWS connectivity

- Primary: Direct Connect at hnd (`dxvif-a/b` on `br-01.hnd ge-0/0/4.*`).
- Backup: site-to-site VPN from `tun-01.nrt` to the VPC. It is routed at L3 `br-01.nrt` → `tun-01.nrt` → AWS VPN, unlike the L2 bridging tun-01 does for the venue.

## Venue to backbone

```
venue LAN ─ cs-01 ─┬─ nat-41/42, nat-61/62 ─┬─ er-01 ─ ge-0/0/5.{10,11,20,21,30,31} ─ tun-01.venue ─ NGN circuit A ─┐
                   └────────────────────────┴─ er-02 ─ ge-0/0/5.{10,11,20,21,30,31} ─ tun-02.venue ─ NGN circuit B ─┤
                                                                       tun-01.hnd ─ br-01.hnd ─ DX, transit ◄───────┤
                                                                       tun-01.nrt ─ br-01.nrt ─ transit, AWS VPN ◄──┤
                                                                       tun-01.itm ─ br-01.itm (West venues only) ◄──┘
```

- The venue normally has two NGN circuits, one on each of tun-01 and tun-02. Everything from circuit to cs-01 is redundant. The exception is the WLC, which has a cold standby.
- Each `er-0x` has VLAN sub-interfaces that the venue `tun-0x` bridges at L2 over EtherIP across NGN to the PoP's `tun-01`, and on to `br-01`. eBGP (v4 and v6) runs directly between `er-0x` and `br-01` over these links.
- Unit numbers: `.10/.11` = hnd, `.20/.21` = nrt, `.30/.31` = itm. On `tun-0x.venue` they are `Tunnel10/11`, `20/21`, `30/31`. The `x0` tunnel is EtherIP over IPsec (IKEv2) and the `x1` tunnel is plain EtherIP over IPv6. Plain EtherIP is the more stable and MTU-friendly of the two on NEC IX.
- A plain EtherIP tunnel reports `ifOperStatus` up even when nothing passes through it, so judge a path by its BGP session.
- On `er-0x`, the `x0` links are the `upstream-private` BGP group and the `x1` links are `upstream-public`. IPv6 cannot be told apart as private or public, so IPv6 to the venue rides the IPsec (`x0`) links, and IPv6 can be the majority of traffic. Heavy traffic on `Tunnel10/20` is therefore normal, and plain EtherIP cannot take it over. Public IPv4 prefers `x1`.

### Traffic distribution between hnd and nrt

Measured at Kaigi on Rails 2026 Day 1 (10:00 JST, 30 min average, about 230 clients):

- **Venue to Internet** is spread by ECMP on `er-0x` (`upstream-public` has `multipath` and `export-multipath` load-balance per flow). hnd and nrt carried 59% / 41% of what the venue sent through the tunnels.
- **Internet to venue** is skewed: transit ingress was 143 Mbps at `br-01.nrt` and 28 Mbps at `br-01.hnd`, so about 68% of traffic toward the venue came through nrt (157 vs 73 Mbps on the PoP tunnels).
- `br-01.hnd` and `br-01.nrt` export identical routes to AS59128 (`transit-out-filter`, no prepend, MED or communities) and have the same local preference, so the skew comes from how AS59128 (KMC) and its upstreams choose an entry point, not from our config. Shifting it needs a prepend or community change on one `br-01` or a request to KMC.
- The `hnd` transit neighbor description says `rola.srh`, but the interface alias names `mahiru.srh738` (stale copy of the nrt description).
- `er-0x ge-0/0/5.1` ↔ `tun-0x gi1.1` (`10.33.22.166/167`, `.168/169`) is the routed link to the tunnel boxes.
- Event-dependent extras:
  - `tun-03`: a cellular backup tunnel, used in years when NGN had to be disconnected every night.
  - `wire-01..04` with `as-01`: a WireGuard interconnect between two venue buildings at RubyKaigi 2026, where `as-01` was the L3 switch of the second building, like cs-01.
  - `show-01`.

## Venue core

- `cs-01`: Juniper EX virtual chassis (members 0 and 1) and the L3 gateway for every venue VLAN (irb). It uplinks to er-01/02 at `ge-0/0/23`, `ge-1/0/23`. Edge switches connect on single-member LACP bundles `ae0..ae7`. The WLC is on `ae10`.
- `er-01/02`: Junos SRX edge routers that hold the BGP sessions to the backbone.
- `nat-41/42` (NEC IX, IPv4 NAPT) and `nat-61/62` (Linux, NAT64/SIIT with BIRD and conntrack) sit between cs-01 and er-0x.
- `xs-01/02`: distribution switches for the eXternal circuits (the NGN handoffs to the tun boxes).
- `cloudprober-01/02.venue`: in-venue probers, managed by itamae.
- `es-*`: Cisco IOS edge switches feeding the APs, named `es-<location>-NN`. They usually cascade (`-02` hangs off `-01`) but sometimes connect straight to cs-01. Some APs plug straight into cs-01.

Per-event wiring (cs-01 port to switch or AP) is in the event's record, for example [Kaigi on Rails 2026](events/kor26/README.md#venue-wiring).

## VLANs and subnets (venue)

| VLAN | Name | IPv4 (gateway on cs-01 irb) | IPv6 | Kea id | Used by |
|---|---|---|---|---|---|
| 200 (native on AP ports) | air | `10.33.2.0/24` (.254) | `cab1::/64` | 102 | APs (CAPWAP), WLC management `10.33.2.2` |
| 300 | life | `10.33.1.0/24` (.254) | `caa0::/64` | 101 | last-resort/management SSID `empurple`, WLC `life` interface |
| 400 | usr | `10.33.64.0/20` (`10.33.79.254`) | `caaa::/64` | 400 | attendee SSIDs, WLC `usr` interface |
| 410 | cast | `10.33.21.0/24` (.254) | `caa1::/64` | 410 | video crew, outbound streaming |
| 1000 | mgmt | `10.33.100.0/24` (.254) | `cab0::/64` | 1000 | device management, WLC service port `10.33.100.10` |

The IPv6 prefixes are all under `2001:df0:8500::/48`. tkyk uses `10.33.30–32.0/24`.

## Wi-Fi

- One AireOS controller, `wlc-01.venue` (system name `rubykaigi-wlc`), on `cs-01 ae10`, with a cold standby unit. AP license: 70, platform max: 150.
- AP naming is `ap-<location>-<XY>`, where the two digits are an X/Y grid position within the location. Location codes: `tra`/`trb`/`trc` track A/B/C, `lb<floor>` lobby, `fo<floor>` foyer (floor 0 = basement), `int` interpreter room, `off` staff office, `noc` NOC area (rack space for the L3 backbone). `unknown-*` means an AP the WLC has not named yet. Models are AIR-AP2802I (some run slot 0 in 5 GHz XOR mode) and AIR-AP1852I.
- 5 GHz only is the standard. The 802.11b network stays disabled for RF and stability reasons, since band steering is unreliable.
- SSIDs, named after the event:

| WLAN | SSID | Interface | Purpose |
|---|---|---|---|
| 10 `usr` | `<event>` | usr | main attendee SSID, IPv6-mostly and any current experiments |
| 3 `usrlegacy` | `<event> Legacy` | usr | "safe mode": every experiment off, IPv6-mostly included |
| 2 `life2` | `empurple` | life | last-resort and management access, the current `life` SSID |
| 1 `rkm` | `rkm` | life | deprecated predecessor of `empurple`, kept disabled |
| 14 `usr24` | `24rk` | usr | normally emergency 2.4 GHz supply; also used as a test SSID that mirrors WLAN 10 with one setting changed (see `wifi/aireos.md`) |

- **IPv6-mostly:** the WLC's DHCP proxy adds option 82 with remote-id `apname:ssid`. Kea class `main_ssid` sends option 108 (v6-only-preferred) unless the SSID ends in `Legacy`, so capable clients drop IPv4 and use NAT64 through nat-61/62. Keep the `Legacy` suffix when renaming SSIDs.
- AP mode: APs run FlexConnect (group rk-venue, local switching; ACL `rk-nodisco` blocks mDNS, LLMNR, SSDP, WS-Discovery and NetBIOS) to work around an unresolved problem: in central switching, the WLC stopped forwarding Router Advertisements to clients. Some APs ran local mode at Kaigi on Rails 2026 without that problem. See [`wifi/troubleshooting.md`](wifi/troubleshooting.md#3-flexconnect-versus-local-mode).
- RADIUS servers are configured on the WLC, but no SSID uses them. That config is stale.

## Services the venue depends on

| Service | Address | Where it runs |
|---|---|---|
| DHCPv4 (Kea, MySQL leases) | `10.33.136.67`, `10.33.152.67`, the WLC's DHCP servers | AWS (EKS `general` nodes), so venue DHCP needs the backbone plus DX or the nrt VPN. Lease time is 1200 s. |
| DNS for attendees | `192.50.220.164/165` (`resolver.rubykaigi.net`, DoH/DoT via `unbound-envoy`) | Unbound on EKS `onpremises` nodes. Their subnet's default route goes to the on-premises backbone (AS59128) rather than AWS, so DNS answers match where conference traffic actually leaves. |
| DNS for infrastructure | `10.33.136.53`, `10.33.152.53` | AWS |
| Syslog | `10.33.136.14` (fluentd NLB) | AWS |
| SNMP traps | `10.33.136.14:162` (syslog NLB, trapbridge to EventBridge) | AWS |
| TFTP | `10.33.136.67` | AWS |
| NTP | `time.google.com` (`216.239.35.0/4/8/12`) | external |

## Expected-down targets and quiet periods

Before calling one of these an outage, check whether the current event uses it:

- For an NTT East venue: itm tunnels (`Tunnel30/31`) and BGP on `er-0x ge-0/0/5.30/.31`.
- Devices the event does not deploy (Kaigi on Rails 2026: `wire-01..04`, `as-01`, `show-01`, `tun-03`), and cs-01 ports tagged for another event.
- `cloudprober-01/02.venue` before they are connected.
- `tkyk` lab devices (silenced).
- During the off-season, and up to the start of an event, a catch-all Alertmanager silence (`alertname=~.+`) mutes everything. It is lifted on day 1. Before then, `am-alerts` shows everything as suppressed, which is normal.

At an East venue the nrt paths (`.20/.21`) should be up. If they are down, that is a real loss of redundancy.
