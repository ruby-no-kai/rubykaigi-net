#!/bin/sh
# Diffs two WLANs' `show wlan N` output, ignoring spacing and counters, to prove a test WLAN mirrors production.
# Usage: wlan_diff.sh WLAN_A WLAN_B   e.g. wlan_diff.sh 10 14
set -u
[ $# -eq 2 ] || { echo "usage: $0 WLAN_A WLAN_B" >&2; exit 64; }
cd "$(git rev-parse --show-toplevel)"
dir=$(mktemp -d tmp/wlan_diff.XXXXXX)
for n in "$1" "$2"; do
  timeout 60 ruby misc/ssh_cli.rb -s "${WLC_SESSION:-wlc-01.venue}" run "show wlan $n" |
    sed 's/  */ /g' | grep -vE '^\s*$|Number of Active|^ *[0-9a-f]{2}(:[0-9a-f]{2}){5}' > "$dir/$n"
done
diff "$dir/$1" "$dir/$2"
