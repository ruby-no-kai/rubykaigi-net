# Hiatus

Hiatus is the time between conferences, from the end-of-event teardown until the pre-event readiness check of the next one. The venue network is physically gone, and the backbone and AWS side stay up at minimum cost.

## What is down

- All venue (`*.venue`) devices: `er-01/02`, `cs-01`, `wlc-01`, `es-*`, `tun-01/02`, `nat-41/42`, the APs and `cloudprober-*`. Their SSH, syslog and SNMP traps stop.
- The VPC NAT that glazed uses to reach AWS APIs is shut down (`tf/glazed`). S3 and SSM stay reachable over IPv6 through the egress-only gateway, and the glazed github step runs in a Lambda function outside the VPC to keep reaching GitHub.
- Catch-all Alertmanager silence `alertname=~.+` mutes everything; `am-alerts` shows all alerts as suppressed. It is lifted on day 1.
- Cost-saving shutdowns of backbone-side targets are tracked in [`topology.md`](topology.md#expected-down-targets-and-quiet-periods).

## What is not an incident

- No venue node on the glazed status page at `https://rubykaigi.net/glazed`, and no new venue backups. They are out of the inventory, so there are no `fetch: Net::SSH::ConnectionTimeout` failures either; the last backups stay in `glazed/hosts` and S3.
- BGP backward-transition traps from backbone routers (`br-01.*`) for peers that belong to the venue.
- No attendee clients, and no Wi-Fi metrics for the venue.

## glazed

`local hiatus` at the top of `glazed/glazed.jsonnet` switches the config:

| | Normal | `hiatus = true` |
|---|---|---|
| Venue hosts | in the inventory | left out of the inventory, not backed up at all |
| Interval | 900 s, retry 60 s | 86400 s |

To enter or leave hiatus, flip the constant, run `./gen-glazed.rb`, commit the regenerated `gen/glazed/glazed.json` and apply `tf/glazed`. Leaving it also needs the NAT back on and the venue hosts reachable. `tf/glazed/trapbridge.tf` keeps its venue device mappings.

## Entering and leaving

- Enter: finish the teardown ([`event-operations.md`](event-operations.md#end-of-event-teardown)), record "Left in place" in `events/<event>/README.md`, set `hiatus = true`, and apply `tf/glazed`.
- Leave: set `hiatus = false` and apply `tf/glazed`, bring the venue up, name the APs and assign groups ([`sops/`](sops/)), run the readiness check ([`event-operations.md`](event-operations.md#pre-event-readiness-the-evening-before-day-1)), and lift the silence on day 1.
- Between those, work on backbone nodes (`br-01.{itm,nrt,hnd}`, `tun-01.{itm,nrt,hnd}`, `recon-01.nrt`) is the normal hiatus job, since they are still up.
