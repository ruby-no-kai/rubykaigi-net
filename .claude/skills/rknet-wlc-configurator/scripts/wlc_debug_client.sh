#!/bin/sh
# Captures `debug client MAC` on wlc-01 for SECONDS (default 300, one 180 s cycle plus margin) into tmp/, then turns debug off.
# Usage: wlc_debug_client.sh MAC [SECONDS] [TAG]   Run in the background; uses its own `wlc-dbg` CLI session slot.
# A second `debug client` replaces the first, and enabling any WLAN ends the capture.
set -u
[ $# -ge 1 ] || { echo "usage: $0 MAC [SECONDS] [TAG]" >&2; exit 64; }
mac=$1 secs=${2:-300} tag=${3:-$(echo "$1" | tr -d : | tail -c 5)}
cd "$(git rev-parse --show-toplevel)"
out=tmp/wlc_debug_client_${tag}_$(date +%m%d-%H%M).txt
c() { timeout $((secs + 60)) ruby misc/ssh_cli.rb -s wlc-dbg "$@"; }

c close >/dev/null 2>&1
c open --dialect aireos --idle-timeout 0 wlc-01.venue.rubykaigi.net > "$out" || { echo "open failed (CLI session limit?)" >&2; exit 1; }
c run "debug client $mac" >> "$out"
c wait --until 'XXNEVERMATCHXX' --timeout "$secs" >> "$out" 2>&1
c run 'debug disable-all' >> "$out"
c run 'show debug' | grep -iE 'enabled|client' || true
c close >/dev/null
echo "$out"
grep -nE 'MN_|reasonCode|Deauth|Change state to|DHCP (transmitting|received)' "$out" | head -40
