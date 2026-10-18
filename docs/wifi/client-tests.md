# Client-side tests to hand a user (macOS)

Users paste output back (ifconfig, tcpdump, scutil). Give each command with what each outcome means. Addresses are Kaigi on Rails 2026's; take current ones from [`../topology.md`](../topology.md).

```bash
scutil --dns | grep -m4 nameserver          # is a resolver still configured (RDNSS from the RA)?
ndp -rn; ndp -an | grep -i en0              # default router and its expiry; neighbour states
sudo tcpdump -ni en0 'icmp6 && ip6[40] >= 133 && ip6[40] <= 136 || port 53'   # RS/RA/NS/NA and DNS
sudo tcpdump -ni en0 'icmp6 && (ip6[40] == 135 || ip6[40] == 136)'            # NS/NA only

dig +time=2 +tries=1 @2001:df0:8500:ca6d:53::c rubykaigi.org     # venue resolver over native IPv6 (SIIT on nat-61/62)
dig +time=2 +tries=1 @2001:df0:8500:ca6d:53::d rubykaigi.org
dig +time=2 +tries=1 -b <one global source address> @2001:df0:8500:ca6d:53::c rubykaigi.org   # repeat per source address
dig +time=2 +tries=1 @2001:df0:8500:ca64:a9:8200:c032:dca4 rubykaigi.org   # same resolver through NAT64 (PREF64)
dig +time=2 +tries=1 @192.50.220.164 rubykaigi.org                         # through CLAT
curl -6 -sS -m5 -o /dev/null -w '%{http_code}\n' https://rubykaigi.org/
```

- ca6d:53::c/d fail but the NAT64 and CLAT paths answer: the SIIT path (nat-61/62) or the route to `ca6d::/64` is at fault, not unbound.
- Only some source addresses fail: suspect ECMP to one bad nat box, or neighbour state for that address on cs-01 (`show ipv6 neighbors | match <mac>`).
- No RA in the capture for several minutes while RS go out: RA delivery to the client (see [`troubleshooting.md`](troubleshooting.md#3-flexconnect-versus-local-mode)).
