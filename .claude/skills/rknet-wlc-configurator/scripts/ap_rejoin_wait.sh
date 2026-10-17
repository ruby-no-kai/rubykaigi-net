#!/bin/sh
# Waits until COUNT APs matching REGEX are joined in `show ap summary`, printing the count every 30 s. Gives up after MAX_SEC.
# Usage: ap_rejoin_wait.sh REGEX COUNT [MAX_SEC=600]   e.g. ap_rejoin_wait.sh '^ap-(tra|fo0)-' 23
set -u
[ $# -ge 2 ] || { echo "usage: $0 REGEX COUNT [MAX_SEC]" >&2; exit 64; }
re=$1 want=$2 max=${3:-600}
cd "$(git rev-parse --show-toplevel)"
deadline=$(( $(date +%s) + max ))
while :; do
  n=$(timeout 60 ruby misc/ssh_cli.rb -s "${WLC_SESSION:-wlc-01.venue}" run 'show ap summary' | grep -cE "$re")
  echo "$(TZ=Asia/Tokyo date +%T) $n/$want joined"
  [ "$n" -ge "$want" ] && exit 0
  [ "$(date +%s)" -ge "$deadline" ] && { echo "gave up after ${max}s" >&2; exit 1; }
  ruby -e 'sleep 30'
done
