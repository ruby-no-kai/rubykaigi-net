---
name: rknet-observability
description: How to read the RubyKaigi network's monitoring data (Prometheus and Alertmanager on the rknet EKS cluster, Grafana dashboards, device syslog and pod logs in CloudWatch Logs, Kubernetes state, and glazed's redacted device configuration backups in S3) while helping NOC staff keep the conference Wi-Fi stable. Use when asked how the Wi-Fi or network is doing, how many clients are connected, why an alert fired, whether an AP, link, BGP peer, NAT, DHCP or DNS is healthy, to look at syslog of a router or WLC, to check pods or logs on the cluster, to read or diff a device's configuration, or to trigger a fresh config backup, even when the user just says "is the network OK?" or "what's going on with wlc-01".
---

# rknet observability for agents

The conference network is monitored from AWS account 005216166247, region ap-northeast-1. The pieces an agent can read directly:

| Source | What it answers | Access from the shell |
|---|---|---|
| Prometheus | Metrics: APs and clients, links, BGP, NAT, DHCP, DNS, ping loss | `scripts/prom.rb` (kubectl service proxy) |
| Alertmanager | Firing, silenced and inhibited alerts | `scripts/prom.rb am-alerts` |
| Grafana | Curated dashboards and their PromQL | anonymous HTTP API at https://grafana.rubykaigi.net |
| CloudWatch Logs | Device syslog, pod logs, Lambda logs | `aws logs` |
| Kubernetes | Network service pods: kea4, unbound, radius, fluentd, Prometheus | `kubectl` |
| S3 `rk-infra/glazed/redacted/` | Device running configs with secrets masked | `aws s3` |
| Device CLI | Live state on a router, switch or WLC | the `ssh-cli` skill |

Always say which source and time range a conclusion comes from. Read-only is the default: never `kubectl apply/delete/rollout/scale/exec` into a pod, edit Grafana, create silences, or change AWS resources unless the user explicitly asks for that change.

## Credentials

AWS credentials come from `mairu` (role `NocAdmin`), usually already in the environment. Check with `aws sts get-caller-identity`, which should show `assumed-role/NocAdmin/...` in 005216166247. If it fails, ask the user to run `! mairu exec ...` or to refresh their session; do not try other credentials. Background: https://scrapbox.io/rknet/AWS.

kubectl uses context `arn:aws:eks:ap-northeast-1:005216166247:cluster/rknet` (EKS cluster `rknet`). If it is missing, `misc/update_kubeconfig.rb` adds one as context `rknet` (run through `rka` per its header). Pass `--context` explicitly when the current context may differ.

## Prometheus and Alertmanager

The web UIs (`prometheus.rubykaigi.net`, `alertmanager.rubykaigi.net`) sit behind ALB OIDC and are for humans. Agents reach the same servers through the Kubernetes API service proxy, which needs only kubectl access and no port-forward:

```bash
S=.claude/skills/rknet-observability/scripts/prom.rb
ruby $S alerts                                     # Prometheus alerts: state, since, severity, name, summary
ruby $S am-alerts                                  # Alertmanager view: active vs suppressed (silenced)
ruby $S query 'sum by (bsnDot11EssSsid) (bsnDot11EssNumberOfMobileStations)'
ruby $S range 'sum(bsnApIfNoOfUsers)' --since 3h --step 300
ruby $S names 'bsnAP'                              # discover metric names
ruby $S labels bsnApIfNoOfUsers                    # label keys and values on a metric
ruby $S --raw query 'up == 0'                      # full JSON
```

The raw form, for anything the script does not cover:

```bash
kubectl get --raw '/api/v1/namespaces/default/services/prometheus-operated:9090/proxy/api/v1/query?query=<urlencoded>'
kubectl get --raw '/api/v1/namespaces/default/services/alertmanager-operated:9093/proxy/api/v2/silences'
```

Notes:

- Scrape interval is 20s and retention 30 days. Use `[2m]` or wider windows with `rate()`.
- Alert rules live in `k8s/prom/rules/*.libsonnet`. Alerts reach Slack via Alertmanager; `send_resolved="false"` alerts (reboots, link changes) never resolve in Slack.
- Off-season, lab (`*.tkyk`) and unused venue targets fire alerts that are silenced. Check `am-alerts` for `suppressed` before treating a `firing` alert as news.
- For metric names, label meanings and the queries the dashboards use, read `references/promql.md` before writing new PromQL.

## Grafana

Anonymous Viewer access is enabled, so the HTTP API works without a token:

```bash
curl -s 'https://grafana.rubykaigi.net/api/search?type=dash-db'                 # list dashboards
curl -s 'https://grafana.rubykaigi.net/api/dashboards/uid/overview'             # panels with PromQL in targets[].expr
```

Dashboards: `overview`, `location`, `dhcp`, `dns`, `ping`, plus BIRD RS, Circuit and Tunnels, IPv6-mostly, Prometheus. Use them to find what the humans are looking at, then run the expressions through `prom.rb`. Link humans to `https://grafana.rubykaigi.net/d/<uid>` when pointing them at a graph. Dashboard JSON is backed up to `s3://rk-infra/grafana/backup/current/` (`tf/grafana/dashboard.tf`).

## Syslog and pod logs in CloudWatch Logs

fluentd (`k8s/syslog`) receives device syslog on UDP 514 (the NLB in `tf/syslog`, bound to the `fluentd` service) and pod logs from fluent-bit, and writes both to S3 `s3://rk-syslog/{syslog,k8s}/year=/month=/day=/` and to CloudWatch Logs:

| Log group | Content | Stream |
|---|---|---|
| `/rkYYnet/syslog` | device syslog | source hostname, such as `tun-01.nrt.rubykaigi.net`; an IP when reverse DNS fails |
| `/rkYYnet/k8s` | container logs | pod name |
| `/aws/eks/rknet/cluster` | EKS control plane | |
| `/aws/lambda/glazed` | config backup runs | |

`YY` is the year in `log_group_name` of `k8s/syslog/config/fluent.conf`; read it there rather than assuming the current year. Each syslog event is JSON with `message`, `severity`, `facility`, `source_host`, `source_addr`.

```bash
aws logs tail /rk26net/syslog --region ap-northeast-1 --since 30m --log-stream-name-prefix wlc-01 --format short
aws logs describe-log-streams --region ap-northeast-1 --log-group-name /rk26net/syslog --order-by LastEventTime --descending --max-items 20
```

Logs Insights (`aws logs start-query` then `get-query-results`, or the CloudWatch MCP tools when available) for searching across devices:

```
fields @timestamp, @logStream, message, severity
| filter severity in ["err", "crit", "alert", "emerg"] or message like /(?i)down|flap|fail/
| sort @timestamp desc | limit 50
```

When CloudWatch looks empty, check each hop before concluding the devices are quiet:

- `ruby $S query 'sum by (tag) (increase(fluentd_input_records_total{tag=~"syslog.*"}[1h]))'`: no `syslog.*` tag means devices are not sending, or the NLB path is broken.
- `ruby $S query 'sum by (plugin_id) (fluentd_output_status_retry_count)'`: a growing count on `out-cwlogs-*` means fluentd cannot write to CloudWatch, typically because the log group in `fluent.conf` differs from the one `tf/syslog/iam.tf` allows after a yearly rename.
- S3 `s3://rk-syslog/syslog/year=YYYY/month=MM/day=DD/` gets the same records as gzipped JSON lines, one object per minute per fluentd pod, partitioned by UTC date, and works as a fallback (`aws s3 cp s3://rk-syslog/syslog/.../OBJECT.gz - | gunzip`).

For pod logs, prefer `kubectl logs` while the pod exists; CloudWatch keeps them after the pod is gone.

## Kubernetes

Everything conference-facing runs in namespace `default`:

| Workload | Purpose | Manifest |
|---|---|---|
| `kea4` | DHCPv4 (MySQL lease DB) | `k8s/dhcp` |
| `unbound`, `unbound-envoy` | DNS cache, DoH/DoT | `k8s/dns-cache` |
| `radius` | 802.1X for the WLC | `k8s/radius` |
| `fluentd`, `fluent-bit` | syslog and pod logs | `k8s/syslog` |
| `tftp-*` | device boot/config files | `k8s/tftp` |
| `prometheus-kube-prometheus-stack-0`, `alertmanager-*`, `*-exporter`, `grafana` | monitoring | `tf/prom`, `tf/grafana` (Helm via Terraform) |

Nodes come from Karpenter: `general` nodes in AWS and `onpremises` nodes at the venue (taint `dedicated=onpremises`). Network services that must stay local, such as unbound, run on the on-premises nodes, so check `kubectl get nodes -L karpenter.sh/nodepool` and `kubectl get pods -o wide` together when a service looks degraded.

```bash
kubectl get pods -o wide
kubectl get events --sort-by=.lastTimestamp | tail -30
kubectl logs deploy/kea4 --since=15m --tail=200
```

The cluster has no metrics-server, so `kubectl top` fails. Use `container_cpu_usage_seconds_total` and `container_memory_working_set_bytes` from Prometheus instead.

Manifests are Jsonnet in `k8s/` rendered by `./gen-k8s.rb` into `gen/k8s/`; humans apply them.

## Device configurations (glazed)

glazed backs up device running configurations on AWS Step Functions (`tf/glazed`, config `glazed/glazed.jsonnet`). Nodes are named `<host>.<site>`, such as `es-tra-01.venue` or `br-01.nrt`.

- Read only `s3://rk-infra/glazed/redacted/<node>`. Secrets, NGN prefixes and circuit IDs are replaced by `[~REDACTED:dgst=…~]`; identical digests mean identical values.
- Never read `glazed/raw/` or `glazed/state/`: raw holds unmasked secrets.
- The bucket is versioned, so diff a device's config over time:

```bash
aws s3 cp s3://rk-infra/glazed/redacted/es-tra-01.venue - | less
aws s3api list-object-versions --bucket rk-infra --prefix glazed/redacted/es-tra-01.venue --query 'Versions[].[VersionId,LastModified]' --output text
aws s3api get-object --bucket rk-infra --key glazed/redacted/es-tra-01.venue --version-id VERSION tmp/es-tra-01.old
```

Backups run every 15 minutes per node (`interval_seconds: 900`), daily at 04:00 JST for all nodes, with an hourly safety-net execution. To take a fresh backup of one node now, after the user asks for it or agrees, start the state machine with a signal:

```bash
aws stepfunctions start-execution --region ap-northeast-1 \
  --state-machine-arn arn:aws:states:ap-northeast-1:005216166247:stateMachine:glazed \
  --input '{"signals":[{"node":"es-tra-01.venue","source":"manual","immediate":true,"workflows":["backup"]}]}'
```

Use `"all_nodes": true` instead of `"node"` for every device. Without `immediate`, the node waits for the 60s debounce. If another execution is already waiting, the new one records the signal and ends at once; the waiting one runs it. Confirm by the object's `LastModified` changing, and look in `/aws/lambda/glazed` or `aws stepfunctions list-executions` when it does not. `glazed signal` from a shell only records a signal and starts nothing, so use Step Functions.

The node list lives in `glazed/glazed.jsonnet`; a device missing there has no backup.

## Triage workflow

When asked whether the Wi-Fi is OK, or something feels slow:

1. `ruby $S am-alerts` and keep only `active` ones.
2. Clients per SSID and per location, compared with an hour ago (`range ... --since 2h`). A sudden drop at one location points to its edge switch or APs; a drop everywhere points to WLC, RADIUS, DHCP or upstream.
3. Edge: `up{job=~".*/snmp-.*"} == 0`, link changes and errors on `es-*`, AP channel utilization and per-radio users.
4. Services: Kea assigned vs total per subnet, Unbound SERVFAIL ratio, RADIUS accept/reject rate, `kubectl get pods -o wide`.
5. Upstream: cloudprober loss, BGP peers, transit and tunnel traffic, NAPT cache overflows, NAT box CPU and conntrack.
6. Syslog of the suspected device for the same window, then the device CLI through the `ssh-cli` skill if the cause is still unclear.

Report findings with the query, the numbers and the time window, and leave fixes to the humans unless asked.

## Additional resources

- `references/promql.md`: jobs and their config files, metric families, label meanings and proven queries for Wi-Fi, links, routing, NAT, DHCP, DNS and cloudprober.
- `scripts/prom.rb`: Prometheus and Alertmanager queries through kubectl.
- `ssh-cli` skill: live device CLI with secrets masked.
