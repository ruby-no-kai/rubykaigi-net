# Cloudprober

Cloudprober measures latency and packet loss between sites (on-premises data centers, the AWS VPC and conference venues), as well as between rooms within each venue. These measurements help detect quality problems with internet circuits and inter-room cabling.

Past incidents illustrate what these measurements should help us detect early:

- At RubyKaigi 2022, probes traversing FLET'S circuits showed high packet loss from the beginning of the conference. The circuit later became unusable, and the cause was traced to failed equipment at the NTT exchange.
- At Kaigi on Rails 2025, poor-quality inter-room cabling only linked at 100 Mbps. Packet loss increased when talks started in the affected room, making the problem detectable under load.

The goal is to detect these signs of degraded connectivity as early as possible, before they develop into a complete outage or disrupt sessions.

To make these measurements, we deploy Cloudprober at conference venues and in AWS. Results are available on Prometheus and in the [Grafana Ping dashboard](https://grafana.rubykaigi.net/d/ping).

## Probers

- AWS: EC2 instance `cloudprober-az-c` in ap-northeast-1c, provisioned by [`tf/cloudprober/`](../tf/cloudprober/).
- Venues: one mini PC per venue, normally connected directly to that venue's core switch (`cs`), provisioned by [`itamae/roles/cloudprober/`](../itamae/roles/cloudprober/). For a single-venue event, the prober is `cloudprober-01.venue.rubykaigi.net`. RubyKaigi 2026 used two venues, each with its own FLET'S circuits. `cloudprober-02.venue.rubykaigi.net` was deployed at the second venue to measure its connectivity.

Cloudprober runs in Docker under `cloudprober.service`. The shared [probe configuration](../itamae/roles/cloudprober/files/etc/cloudprober.cfg) defines `ping4` and `ping6`, each with a 5-second interval and a 2-second timeout. Latency is measured in milliseconds.

Prometheus discovers probers through the private SRV record `_prometheus._http.cloudprober.rubykaigi.net`, on TCP port 9313. Membership is managed in [`tf/cloudprober/route53.tf`](../tf/cloudprober/route53.tf).

Cloudprober instances, including the AWS instance, are shut down for the [hiatus between events](hiatus.md).

## Probe targets

Both AWS and venue probers use the same target lists:

- Edge switches (`es`) in each room. Probes from the venue mini PC check the inter-room cabling; probes from AWS also traverse the path to the venue.
- Border routers (`br`) and tunnel routers (`tun`) at each data center, to measure circuit latency and loss.
- Tunnel point-to-point addresses between `br` and venue edge routers (`er`). Multiple FLET'S circuits connect them; probing the individual tunnel addresses helps identify which circuit has a problem.
- Other infrastructure, including `nat-4x`, `nat-6x` and the WLC, to check their reachability.

## Update probe targets

[`gen-cloudprober.rb`](../gen-cloudprober.rb) selects addresses from Route 53 using name patterns and address ranges in `TARGETS`. It generates separate IPv4 and IPv6 lists. Event-specific exclusions are also in this script.

From the repository root, with AWS credentials for rknet:

```sh
# Generate locally; inspect gen/cloudprober/targets{4,6}.json.
ruby gen-cloudprober.rb

# Regenerate and upload both lists to S3.
ruby gen-cloudprober.rb --apply
```

The published files are `s3://rubykaigi-public/rknet/cloudprober/targets4.json` and `targets6.json`. Probers fetch them over HTTPS every 300 seconds; no restart is needed.

The JSON contains target IP addresses so probes do not depend on resolving target names when DNS is broken. Regenerate the lists when target IP addresses change.

## Check results

For agents, the [observability helper](../.claude/skills/rknet-observability/SKILL.md) queries Prometheus through kubectl:

```sh
S=.claude/skills/rknet-observability/scripts/prom.rb
ruby "$S" query 'up{job="scrapeConfig/default/cloudprober"}'
ruby "$S" query '1 - rate(cloudprober_success{probe=~"ping[46]"}[2m]) / rate(cloudprober_total{probe=~"ping[46]"}[2m])'
```

The loss query returns a ratio per `instance` (prober), `probe` (`ping4` or `ping6`) and `dst` (destination). Compare the same destination across probers to distinguish source/path failures from destination failures. `up` checks metrics collection; an empty result does not mean zero loss.

[`HighPacketLossRate`](../k8s/prom/rules/cloudprober.libsonnet) fires when loss exceeds 30% over a 1-minute rate window.

This alert detects severe loss. Persistent loss at a lower percentage can also indicate a problem, while an isolated spike may be caused by normal traffic load. Criteria for automatically investigating lower loss, including thresholds and durations, are not yet defined.
