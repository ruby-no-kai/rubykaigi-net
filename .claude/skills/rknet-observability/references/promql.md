# rknet Prometheus: metric families and proven queries

The queries below come from the Grafana dashboards (Overview, Location, DHCP, DNS, Ping) and from `k8s/prom/rules/*.libsonnet`. Run them with `scripts/prom.rb query '...'`. Replace Grafana's `$__rate_interval` with a literal such as `2m`.

## Jobs and where their scrape config lives

| `job` label | What | Config |
|---|---|---|
| `scrapeConfig/default/snmp-hi-ix` | NEC IX routers: tun-*, nat-4x, recon-01 (if_mib, bgp4, nec_ix) | `k8s/prom/snmp.jsonnet` |
| `scrapeConfig/default/snmp-hi-cisco-esw`, `snmp-lo-cisco-esw` | Cisco IOS edge switches es-* | same |
| `scrapeConfig/default/snmp-lo-juniper-srx`, `snmp-lo-juniper-ex` | br-*, er-*, cs-* | same |
| `scrapeConfig/default/snmp-lo-cisco-wlc` | wlc-01.venue (AireOS, APs and clients) | same |
| `scrapeConfig/default/cloudprober` | ping4/ping6 probes from cloudprober EC2 instances (DNS-SD `_prometheus._http.cloudprober.rubykaigi.net`) | `k8s/prom/cloudprober.jsonnet`, `tf/cloudprober` |
| `scrapeConfig/default/nat-6x`, `nat-6x-bird`, `nat-6x-conntrack` | Linux NAT64/SIIT boxes nat-61/62 (node_exporter, BIRD, conntrack) | `k8s/prom/nat-6x.jsonnet` |
| `scrapeConfig/default/wire`, `wire-bird` | wire-01..04 venue boxes | `k8s/prom/wire.jsonnet` |
| `scrapeConfig/default/show`, `show-bird` | show-01.venue | `k8s/prom/show.jsonnet` |
| `scrapeConfig/default/tito` | attendee check-in counts | `k8s/prom/tito.jsonnet` |
| `default/kea4` | Kea DHCPv4 pods | `k8s/dhcp/monitoring.jsonnet` |
| `default/unbound-envoy`, unbound | DNS cache (Unbound behind Envoy DoH/DoT) | `k8s/dns-cache/monitoring.jsonnet` |
| `default/fluentd` | syslog collector | `k8s/syslog/monitoring.jsonnet` |
| `cloudwatch-exporter-*` | AWS metrics (EC2, ELB, NAT GW, RDS) | `tf/prom/cloudwatch-exporter.config` |

SNMP modules are generated from `tf/prom/snmp-exporter.config` by `tf/prom/gen-snmp-exporter-config.rb`. Every target has an `instance` FQDN and an `instance_short` such as `tun-01.venue`.

## Wi-Fi (WLC)

Labels: `bsnAPName` (`ap-<location>-NN`), `bsnAPIfSlotId` (0 = 2.4 GHz, 1 = 5 GHz), `bsnAPIfType` (1 = 2.4 GHz, 2|3 = 5 GHz), `bsnDot11EssSsid`.

```promql
# Clients per SSID
bsnDot11EssNumberOfMobileStations
# Clients per location
sum by (loc) (label_replace(bsnApIfNoOfUsers, "loc", "$1", "bsnAPName", "^ap-(.+?)-.*$"))
# APs known per location (one series per AP)
count by (loc) (label_replace(bsnApIfNoOfUsers{bsnAPIfSlotId="0"}, "loc", "$1", "bsnAPName", "^ap-(.+?)-.*$"))
# Busiest radios; the WifiApTooManyUsers alert fires above 80 for 5m
topk(10, bsnApIfNoOfUsers)
# Channel utilization (%), channel, tx power level per radio
bsnAPIfLoadChannelUtilization{bsnAPIfType=~"2|3"}
bsnAPIfPhyChannelNumber
bsnAPIfPhyTxPowerLevel
# Retries and failures, as rates
topk(10, rate(bsnAPIfDot11RetryCount[5m]))
topk(10, rate(bsnAPIfDot11FailedCount[5m]))
bsnAPIfDBNoisePower
```

Locations used by the Location dashboard: `tra trb trc are fh1 fh2 fa1 fa2 fa3 lb1 lb2 int off noc` (they change per venue; read the label values). AP names starting with `unknown-` are APs not yet named on the WLC.

## Links and traffic

SNMP counters are not `_total`-suffixed, so Prometheus prints a "might not be a counter" info. Ignore it.

```promql
# Backbone (br/er) throughput, bps
max by (instance, ifName) (rate(ifHCInOctets{instance=~"(br|er)-.*",ifName=~"ge-.*|ae[0-9]+"}[2m]) * 8)
# Internet transit and AWS uplinks, by interface description
irate(ifHCInOctets{instance=~"br-.+",ifAlias=~"^Transit:.+"}[2m]) * 8
irate(ifHCInOctets{instance=~"br-.+",ifAlias=~"^Uplink:.+"}[2m]) * 8
# Site tunnels from the venue routers
irate(ifHCOutOctets{instance=~"tun-.+\\.(venue|tkyk)\\.rubykaigi\\.net",ifName=~"Tunnel.+\\.0$"}[2m]) * 8
# Edge switch uplinks of a location
irate(ifInOctets{instance=~"^es-tra-.+$",ifDescr=~"^Port-channel.+$"}[1m]) * 8
# Up links per device; links that flapped; slow links; errors
sum by (instance_short) (ifOperStatus == 1 and on (instance_short, instance, ifIndex) ifAdminStatus == 1)
changes(ifOperStatus[10m]) > 0
ifSpeed{instance!~"^wlc-.+$"} < 1000000000 and ifSpeed > 0 and ifOperStatus == 1 and ifAdminStatus == 1
increase(ifInErrors[10m]) > 0
increase(ifOutDiscards[10m]) > 0
# Reachability of SNMP targets
up{job=~".*/snmp-.*"} == 0
resets(sysUpTime[30m]) > 0
```

## Routing

```promql
bgpPeerState{bgpPeerState="established"} < 1                     # NEC IX
jnxBgpM2PeerState{jnxBgpM2PeerState="established"} < 1           # Junos
bird_protocol_up == 0                                             # nat-6x, wire, show
jnxBgpM2PrefixInPrefixesAccepted
```

## NAT and IPv6-mostly

```promql
# IPv4 NAPT sessions on NEC IX nat-4x; overflows drop new flows
naptCacheEntries{instance=~"nat-4.*"}
rate(naptCacheOverflows[3m]) > 0
# NAT64/SIIT boxes
sum by (instance_short) (conntrack_labelled_entries{instance=~"nat-6.*",label=~"snat:.*"})
node_nf_conntrack_entries / node_nf_conntrack_entries_limit
# Downstream inbound traffic split (v6 via nat-6x, v4 via nat-4x, total at cs)
sum(irate(node_network_receive_bytes_total{instance=~".*nat-6.*",device="enp1s0"}[2m])) * 8
sum(irate(ifHCInOctets{instance=~"nat-4.*",ifName="GigaEthernet0.2"}[2m])) * 8
sum(irate(ifHCInOctets{instance=~"cs-.*",ifName=~"ge-./0/23"}[2m])) * 8
```

## Router health

```promql
picoSchedRtUtl1Min                                   # NEC IX CPU %, alerts at 70/80
jnxOperatingCPU{jnxOperatingDescr=~".*Routing Engine.*"}
(1 - avg by (instance_short) (irate(node_cpu_seconds_total{instance=~"^nat-6.+$",mode="idle"}[1m]))) * 100
jnxDomCurrentRxLaserPower                            # optics
ciscoEnvMonTemperatureStatusValue
```

## Reachability (cloudprober)

Labels: `instance` (the prober, such as `10-33-133-139.apne1c.cloudprober.rubykaigi.net:9313`), `probe` (`ping4`/`ping6`), `dst` (target FQDN).

```promql
# Loss ratio per prober and destination; HighPacketLossRate fires above 0.3
1 - rate(cloudprober_success{probe=~"ping[46]"}[2m]) / rate(cloudprober_total{probe=~"ping[46]"}[2m])
# Mean and p95 latency (microseconds)
rate(cloudprober_latency_sum{probe="ping4"}[2m]) / rate(cloudprober_latency_count{probe="ping4"}[2m])
histogram_quantile(0.95, rate(cloudprober_latency_bucket{probe="ping4"}[2m]))
```

## DHCP (Kea)

Use `max by (subnet)` over `kea_dhcp4_addresses_*`. The `kea_dhcp4_pool_*` series read around 1.8e19 (an underflowed counter) and are not usable.

```promql
max by (subnet) (kea_dhcp4_addresses_assigned_total) / max by (subnet) (kea_dhcp4_addresses_total)
max by (subnet) (kea_dhcp4_addresses_declined_total)
sum by (operation) (rate(kea_dhcp4_packets_received_total[2m]))
sum by (operation) (rate(kea_dhcp4_packets_sent_total[2m]))
```

## DNS cache and RADIUS

```promql
sum by (instance) (irate(unbound_queries_total[2m]))
sum by (instance) (rate(unbound_answer_rcodes_total{rcode="SERVFAIL"}[1m])) / sum by (instance) (rate(unbound_answer_rcodes_total[1m]))
sum by (instance) (rate(unbound_cache_hits_total[1m])) / (sum by (instance) (rate(unbound_cache_hits_total[1m])) + sum by (instance) (rate(unbound_cache_misses_total[1m])))
rate(freeradius_total_access_accepts[2m])
rate(freeradius_total_access_rejects[2m])
```

RADIUS metrics exist only while the radius deployment runs.

## Attendance

```promql
tito_checkin_list_completed            # checked-in attendees, per instance such as rubykaigi/2025
```
