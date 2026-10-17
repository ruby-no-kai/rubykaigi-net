#!/bin/sh
# Sets a static 5 GHz Tx power level on one AP (or `global` to return it to TPC) with the disable/set/enable cycle.
# Usage: cycle.sh AP LEVEL|global   Drops that radio's clients for 1-2 s; needs the user's approval.
# Prints the radio's power line before and after, the JST apply window for the monitor, and the slot-1 count 25 s later.
set -eu
[ $# -eq 2 ] || { echo "usage: $0 AP LEVEL|global" >&2; exit 64; }
ap=$1 level=$2
cd "$(git rev-parse --show-toplevel)"
w() { timeout 60 ruby misc/ssh_cli.rb -s "${WLC_SESSION:-wlc-01.venue}" run "$1"; }
power() { w 'show advanced 802.11a summary' | grep -E "^$ap +[0-9a-f:]+ +1 " || echo "$ap slot 1 not found"; }

echo "before: $(power)"
start=$(TZ=Asia/Tokyo date +%H:%M:%S)
w "config 802.11a disable $ap" >/dev/null
w "config 802.11a txPower ap $ap $level"
w "config 802.11a enable $ap" >/dev/null
end=$(TZ=Asia/Tokyo date +%H:%M:%S)
echo "applied $ap level $level: $start-$end JST"
w "show ap config 802.11a $ap" | grep -E 'Operation State|Tx Power Configuration|Current Tx Power Level|CUSTOMIZED' || true
ruby -e 'sleep 25'
echo "after: $(power)"
echo "slot-1 clients: $(w 'show client summary' | awk -v ap="$ap" '$2 == ap && $3 == 1' | wc -l)"
