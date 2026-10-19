# SOP: edge switch mapping

Every edge switch has a DNS name from its asset tag ([`../asset-tags.md`](../asset-tags.md)), `<asset-tag>.venue.rubykaigi.net` (for example `rk-srnp19a2`), and a fixed DHCP assignment in the management VLAN (`hosts.txt`, rendered into the DHCP and DNS config). A switch therefore comes up at the same address wherever it is plugged in, and nobody configures an IP address on it at setup.

The location name `es-<area>-NN` (see [`../topology.md`](../topology.md)) is a CNAME to the asset tag name. It is what monitoring (`k8s/prom/snmp.jsonnet`, `glazed/glazed.jsonnet`) and humans use. Moving a switch to another area or swapping a unit means editing one CNAME.

Which switch goes where is not planned in advance: whoever mounts a switch records its asset tag against the location, as for APs ([`ap-naming.md`](ap-naming.md)).

## Inputs (prepared by humans)

1. The deployment map: one row per edge switch with its `es-<area>-NN` name and asset tag. In 2026 this was the edge switch sheet of the NOC spreadsheet; ask for it as TSV in a file under `tmp/`.
2. Which management VLAN each switch sits on, only if some switches are on the second venue network (`venue2-vlan1000`). Check `hosts.txt` for the tag; a tag listed only under `mgmt2` must point at `venue2-vlan1000.<asset-tag>.venue.rubykaigi.net.` instead.

## Steps

1. Confirm every asset tag in the map has a fixed assignment: `grep <tag> hosts.txt`. A tag missing there has no address and needs adding to `hosts.txt` first (regenerate with `gen-hosts.rb`).
2. Edit the private zone block (`hosted_zone ... "Z05547502KT77L0O53UWK"`) in `route53/rubykaigi.net.route`. Replace the `es-*` CNAMEs with the new map, one `rrset 'es-<area>-NN.venue.rubykaigi.net.', 'CNAME'` each, `ttl 300`, pointing at `<asset-tag>.venue.rubykaigi.net.`. Delete the entries for areas the venue does not have, so stale names do not look like down switches.
3. Dry-run and apply with roadworker from `route53/` (`bundle exec roadwork -a --dry-run`, then `-a` without it; the exact flags follow the other `.route` changes).
4. Update the same name list in `k8s/prom/snmp.jsonnet` and `glazed/glazed.jsonnet` (`ios(name, 'venue')`), then run `./gen-k8s.rb` and `./gen-glazed.rb` and commit the `gen/` output with them. A name left out of these is not monitored or backed up.
5. Verify from inside the venue network: `dig +short es-<area>-NN.venue.rubykaigi.net` resolves through the asset tag to the management address for every switch, and `show lldp neighbors` on cs-01 agrees with the uplink table in the event README.
6. Record the area to asset tag mapping in `docs/events/<event>/` so the next event can see what was where.

A switch moved after setup needs only step 2 (the CNAME), 3 and 5; the monitoring name list does not change.

## When it goes wrong

- `es-*` does not resolve: the CNAME has not applied, or points at a tag with no `hosts.txt` entry.
- It resolves but the switch does not answer: the asset tag in the map is wrong (someone mounted another unit). Compare the label on the switch with the map; `show lldp neighbors` on the uplink shows the hostname the switch reports.
- Hostname on the switch itself (`show run | i hostname`) is not part of this: SNMP, glazed and SSH go by the DNS name, so the device hostname can stay at its asset tag.
