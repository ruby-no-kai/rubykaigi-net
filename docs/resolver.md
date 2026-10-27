# DNS resolver

We provide a full-service DNS resolver for conference attendees and network infrastructure. It supports classic DNS (Do53) and encrypted DNS through DNS-over-HTTPS (DoH), DNS-over-TLS (DoT) and DNS-over-QUIC (DoQ).

We have a dedicated [DNS dashboard in Grafana](https://grafana.rubykaigi.net/d/dns) for monitoring the resolver.

## Deployment and query handling

The service runs on EKS, using [Unbound](../k8s/dns-cache/config/unbound.conf) for recursive resolution, [dnsdist](../k8s/dns-cache/config/dnsdist.lua) for Do53, DoT and DoQ, and [Envoy](../k8s/dns-cache/config/envoy.libsonnet) for DoH. See the [deployment](../k8s/dns-cache/deployment.jsonnet) for pod layout and listeners.

### Upstream connectivity and egress

Unbound runs on AWS nodes in the VPC's `onpremises` subnets. Its Internet traffic passes through the on-premises data centers and exits through AS59128. This is intentional: DNS resolution should use the same Internet egress AS as attendee traffic.

Egress uses two stages of source NAT: the [private NAT gateways](../tf/core/vpc.tf) perform NAPT, then the on-premises `tun-01` routers translate the gateway addresses to public addresses using static NAT. See the NAT rules on [`tun-01.hnd`](../glazed/hosts/tun-01.hnd) and [`tun-01.nrt`](../glazed/hosts/tun-01.nrt).

These subnets currently lack IPv6 upstream connectivity, so Unbound uses IPv4 to query upstream servers (`do-ip6: no`). Consequently, zones served exclusively by IPv6-only authoritative servers cannot be resolved.

## Client access

### Addresses and routing

Client-facing listeners in dnsdist and Envoy are IPv4-only by design. IPv6 clients reach the service through NAT64, as shown below.

Attendees receive resolver addresses through [DHCPv4](../k8s/dhcp/config/subnet_usr.libsonnet) and [RA RDNSS](../glazed/hosts/cs-01.venue). Both address families reach the same internal NLB through NAT:

| Client-facing IPv6 address | IPv4 address after translation on `nat-6x` | NLB address after NAT at the data centers |
|---|---|---|
| `2001:df0:8500:ca6d:53::c` | `192.50.220.164` | `10.33.136.53` |
| `2001:df0:8500:ca6d:53::d` | `192.50.220.165` | `10.33.152.53` |

IPv4 clients use the middle-column addresses directly. The IPv6 translation is implemented by `nat-61/62`'s [nftables rules](../itamae/roles/plat/templates/etc/nftables/plat.conf) and [SIIT translator](../itamae/cookbooks/xlat/files/etc/systemd/system/xlat-siit.service); the static NAT to the [NLB](../tf/dns-cache/elb.tf) is on [`tun-01.hnd`](../glazed/hosts/tun-01.hnd) and [`tun-01.nrt`](../glazed/hosts/tun-01.nrt).

For tests **inside the VPC**, the client-facing addresses do not work. Use [`origin.resolver.rubykaigi.net`](../tf/dns-cache/route53.tf) or the NLB addresses directly, with `resolver.rubykaigi.net` as the TLS server name and verification identity for encrypted DNS. These tests bypass the client-facing NAT paths; [end-to-end verification](#pre-conference-verification) must run from the venue.

To distribute load, the [attendee DHCP pools](../k8s/dhcp/config/subnet_usr.libsonnet) advertise opposite resolver orders and use Kea's [random allocator](../k8s/dhcp/configmap.jsonnet). RA RDNSS has no equivalent per-client variation.

### Encrypted DNS discovery

Local SVCB records let clients discover encrypted transports from either their configured resolver address (DDR, using `_dns.resolver.arpa.`) or the resolver hostname (using `_dns.resolver.rubykaigi.net.`, per [RFC 9461](https://www.rfc-editor.org/rfc/rfc9461.html)). This allows capable clients to upgrade from Do53 without manual encrypted-DNS configuration.

Automatic verified DDR upgrades rely on a publicly trusted certificate covering the resolver IP addresses; see [TLS certificate and renewal](#tls-certificate-and-renewal).

In both sets, the preferred DoH record includes the unknown ALPN identifier `**` alongside `h3` and `h2`. This deliberate GREASE (Generate Random Extensions And Sustain Extensibility) exercises clients' ability to ignore unknown identifiers and select a supported protocol, helping keep protocol discovery extensible.

## Resolver behavior

### Private answers for rknet domains

Unbound forwards queries for `rubykaigi.net.` and `rubykaigi.org.` to the VPC resolver so attendees receive private answers for selected services and connect through the VPC path.

For example, [`ops-lb.rubykaigi.net`](../tf/ops-lb/alb.tf) points to Global Accelerator in public DNS and directly to the internal ALB in private DNS. Grafana, Prometheus and Alertmanager [use CNAMEs to this name](../route53/rubykaigi.net.route), so attendees using this resolver take the private path to those services.

Private reverse lookups also go to the VPC resolver. The `nodefault` settings remove default local handling where applicable so these lookups can reach the forwarder.

### DNSSEC validation and local overrides

Unbound validates DNSSEC. Private answers for zones whose public versions are signed may lack the signatures required by the public chain of trust. The scoped `domain-insecure` exceptions allow private reverse answers and local `resolver.arpa.` data without disabling validation elsewhere.

The local overrides for `resolver.rubykaigi.net.` and `ipv4only.arpa.` use `typetransparent` zones. Unbound supplies the configured record types locally and resolves other types normally. For example, the synthetic AAAA records for `ipv4only.arpa.` do not suppress normal lookups for its A records.

### NAT64 prefix discovery

The resolver does not perform DNS64. Its synthetic AAAA records for `ipv4only.arpa.` exist only to let clients discover the NAT64 prefix (Pref64::/n) using [RFC 7050](https://www.rfc-editor.org/rfc/rfc7050.html).

At the venue, the attendee interface on [`cs-01`](../glazed/hosts/cs-01.venue) advertises Pref64::/n through the RA option defined in [RFC 8781](https://www.rfc-editor.org/rfc/rfc8781.html). Clients supporting that option can learn the prefix from RA without DNS-based discovery.

### Error details and resolver information

Unbound enables Extended DNS Errors (EDE), defined in [RFC 8914](https://www.rfc-editor.org/rfc/rfc8914.html), to provide additional details about failures, such as DNSSEC validation errors, beyond the DNS response code.

RESINFO records ([RFC 9606](https://www.rfc-editor.org/rfc/rfc9606.html)) let clients discover resolver capabilities, including QNAME minimisation and supported EDE codes. The configuration comment decodes the hexadecimal `TYPE261` records and shows how to regenerate them.

## TLS certificate and renewal

Let's Encrypt issues a certificate covering `resolver.rubykaigi.net` and all four client-facing IP addresses. [Acmesmith](../tf/acmesmith/acmesmith.tf) automates issuance and renewal; its [hooks](../tf/acmesmith/letsencrypt.jsonnet) deploy the certificate and restart the resolver components so they load it.

Envoy also validates Unbound's certificate against public trust anchors and `resolver.rubykaigi.net` for its upstream DoH connection.

An earlier manual certificate deployment error broke encrypted DNS, but clients fell back to Do53, hiding the failure during ordinary use. Rotation is now automated, but successful DNS resolution alone still does not verify encrypted DNS or certificate renewal.

### Validation of the IP addresses

Internet validators must reach HTTP-01 responders on the same IP addresses that attendees use for DNS. Dedicated [ACME responders](../tf/acme-responder/ec2.tf) [advertise more-specific routes](../itamae/roles/acme-responder/templates/etc/bird/bird.conf.d/acme-responder.conf) to attract Internet traffic, while attendees continue to use the venue's resolver path. Their [nginx configuration](../itamae/roles/acme-responder/templates/etc/nginx/sites-available/default) serves challenge responses that Acmesmith writes to S3.

For the hostname `resolver.rubykaigi.net`, Acmesmith uses the Route 53 challenge responder instead.

## Pre-conference verification

NOC members or coding agents currently perform these checks ad hoc; there is no dedicated verification tool yet.

From the venue network, test each of the four client-facing resolver addresses listed above:

- Test Do53 over UDP and TCP, DoT, DoQ, and DoH over HTTP/1.1, HTTP/2 and HTTP/3 separately. Verify the transport and negotiated HTTP version so fallback cannot hide failures.
- For each transport, resolve `kmc.gr.jp A` and `grafana.rubykaigi.net A`; the latter must return VPC addresses.
- Resolve `1500.dns-test.kmc.jp TXT` with an upstream fetch, not a cached answer. This large-response test covers an upstream MTU failure.
- For each encrypted transport, verify that the served certificate is trusted and within its validity period, and that its SANs contain all four IP addresses and `resolver.rubykaigi.net`.
- Verify that the DDR SVCB records at `_dns.resolver.arpa.` resolve correctly and advertise the expected resolver hostname, address hints, transports and DoH path.

## Privacy considerations

We do not routinely log individual DNS queries. We may log client identifiers and queried domain names only to troubleshoot resolution failures and other errors, including SERVFAIL and DNSSEC validation failures.

We may collect and publish aggregate query statistics. Neither client identifiers nor queried domain names are used to produce these statistics, even in anonymized form.
