#!/bin/bash
# Usage: keepalive.sh   (run in the background)
#
# Types `show sysinfo` every 2 minutes so the WLC's CLI login timeout does not close the
# ssh_cli session (WLC_SESSION, default wlc-01.venue). Skips while apply_plan.sh holds
# its lock, and exits 1 when the session is gone.
set -u
repo=$(cd "$(dirname "$0")" && git rev-parse --show-toplevel)
sess=${WLC_SESSION:-wlc-01.venue}
lock=$repo/tmp/ap-rename/wlc.lock
while true; do
  if [[ -d $lock ]]; then
    echo "$(date +%T) skip (apply_plan running)"
  elif ruby "$repo/misc/ssh_cli.rb" -s "$sess" run 'show sysinfo' > /dev/null 2>&1; then
    echo "$(date +%T) ok"
  else
    status=$?
    echo "$(date +%T) SESSION LOST (exit $status)"
    exit 1
  fi
  sleep 120
done
