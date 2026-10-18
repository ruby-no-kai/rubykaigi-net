---
name: rknet-topology
description: Map of the RubyKaigi / Kaigi on Rails conference network (rknet), covering sites (hnd/nrt/itm/venue/apne1/hot), how the venue reaches the backbone over NTT NGN EtherIP tunnels, transit via AS59128, venue routers, NAT boxes and the core switch, VLANs and subnets, the Cisco WLC with its SSIDs and AP naming, edge switches, and which services (Kea DHCP, Unbound, RADIUS) live in AWS or on-premises. Also says where each fact is recorded so it can be re-derived each year. Use it before triaging or explaining anything that depends on how the network is wired, such as "why is DHCP failing", "which path does venue traffic take", "what is VLAN 400", "what is the Legacy SSID for", "is this BGP peer or tunnel supposed to be up", "which switch feeds ap-tra-12", or when reading alerts, Prometheus labels or device configs that mention rknet hostnames, even when the user never says "topology".
---

# rknet topology

The map lives in `docs/topology.md` so NOC staff can read it too. Read it before answering; this skill only says how to use it.

Sections: sources of truth (`hosts.txt`, glazed, Kea config, LLDP), interface description format, sites and the NTT East/West constraint, venue to backbone (tunnels, units, BGP groups, hnd/nrt traffic split), venue core, VLANs and subnets, Wi-Fi (WLC, AP naming, SSIDs, IPv6-mostly), services the venue depends on, expected-down targets.

- Venue values are a snapshot from the last event. Confirm anything that matters with LLDP, the redacted configs (`rknet-observability`) or the live CLI (`ssh-cli`), and say when the doc and the device disagree.
- Per-event wiring and the state an event left behind are in `docs/events/<event>/README.md`.
- When a fact changes, update `docs/topology.md` (or the event record for event-only facts) rather than this skill.
