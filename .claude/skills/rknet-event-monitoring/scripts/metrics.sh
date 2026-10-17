#!/bin/zsh
# Periodic Prometheus snapshot for an event monitoring loop. Run from anywhere in the repo.
# The grep -v filters in "bgp down" and "loss" hide peers and targets that were expected down at KoR26; edit them per event.
cd "$(git rev-parse --show-toplevel)"
S=.claude/skills/rknet-observability/scripts/prom.rb
q() { ruby $S query "$1"; }
TZ=Asia/Tokyo date +%H:%M
echo "== active alerts"; ruby $S am-alerts | grep -v '^suppressed'
echo "== SSID"; q 'bsnDot11EssNumberOfMobileStations' | sed -E 's/.*Ssid="([^"]*)".* ([0-9]+)$/\1 \2/'
echo "== loc"; q 'sum by (loc) (label_replace(bsnApIfNoOfUsers, "loc", "$1", "bsnAPName", "^ap-(.+?)-.*$"))' | sed -E 's/.*loc="([^"]*)".* ([0-9]+)$/\1=\2/' | tr '\n' ' '; echo
echo "== APs"; q 'count(bsnApIfNoOfUsers{bsnAPIfSlotId="1"})' | awk '{print $NF}'
echo "== total"; ruby $S range 'sum(bsnApIfNoOfUsers)' --since 30m --step 300 | tail -1
echo "== top radios"; q 'topk(5, bsnApIfNoOfUsers)' | sed -E 's/.*SlotId="([0-9])".*APName="([^"]*)".* ([0-9]+)$/\2 s\1 \3/' | tr '\n' ',' ; echo
echo "== top util"; q 'topk(5, bsnAPIfLoadChannelUtilization)' | sed -E 's/.*SlotId="([0-9])".*APName="([^"]*)".* ([0-9]+)$/\2 s\1 \3/' | tr '\n' ','; echo
echo "== snmp down"; q 'up{job=~".*/snmp-.*",instance!~".*tkyk.*"} == 0'
echo "== flaps 20m"; q 'changes(ifOperStatus{instance!~".*tkyk.*"}[20m]) > 0' | sed -E 's/.*ifAlias="([^"]*)".*ifName="([^"]*)".*instance_short="([^"]*)".* ([0-9]+)$/\3 \2 (\1) \4/'
echo "== in errors 20m"; q 'increase(ifInErrors{instance!~".*tkyk.*"}[20m]) > 0'
echo "== resets"; q 'resets(sysUpTime[20m]) > 0'
echo "== tun out errors 20m"; q 'max by (instance_short, ifName) (increase(ifOutErrors{instance_short=~"tun-0.\\.(hnd|nrt|venue)",ifName=~"Tunnel.*"}[20m])) > 0'
echo "== tun peak out Mbps 20m"; q 'max by (instance_short, ifName) (max_over_time((irate(ifHCOutOctets{instance_short=~"tun-01.(hnd|nrt)",ifName=~"Tunnel[12][01]\\.0"}[2m])*8/1e6)[20m:1m]))' | sed -E 's/.*ifName="([^"]*)".*instance_short="([^"]*)".* ([0-9.]+)$/\2 \1 \3/' | tr '\n' ','; echo
echo "== transit Mbps"; q 'sum(irate(ifHCInOctets{instance=~"br-.+",ifAlias=~"^Transit:.+"}[2m]) * 8)/1e6' | awk '{print $NF}'
echo "== bgp down (unexpected)"; q 'jnxBgpM2PeerState{jnxBgpM2PeerState="established"} < 1' | grep -vE 'itm|tkyk|CA22:003|CA22:0044|CA22:0046|CA22:0158|10.33.22.79'
q 'bgpPeerState{bgpPeerState="established"} < 1' | grep -v 10.33.22.78
echo "== kea >30%"; q 'max by (subnet) (kea_dhcp4_addresses_assigned_total) / max by (subnet) (kea_dhcp4_addresses_total) > 0.3'
echo "== servfail max"; q 'max(sum by (instance) (rate(unbound_answer_rcodes_total{rcode="SERVFAIL"}[5m])) / sum by (instance) (rate(unbound_answer_rcodes_total[5m])))' | awk '{print $NF}'
echo "== napt overflow / cpu>40"; q 'rate(naptCacheOverflows[5m]) > 0'; q 'picoSchedRtUtl1Min > 40'
echo "== loss >1%"; q '(1 - rate(cloudprober_success{probe=~"ping[46]"}[5m]) / rate(cloudprober_total{probe=~"ping[46]"}[5m])) > 0.01' | grep -vE 'wire-|as-01|itm|test-cs|er-0.\.venue'
echo "== pods not running"; kubectl --context arn:aws:eks:ap-northeast-1:005216166247:cluster/rknet get pods --no-headers | grep -Ev 'Running|Completed'
