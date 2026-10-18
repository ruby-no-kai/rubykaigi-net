#!/bin/sh
# Keeps the wlc-01 ssh_cli session from hitting the WLC's CLI login timeout (5 minutes at Kaigi on Rails 2026,
# `show sessions`) between scheduled batches. Run in the background; exits 1 when the session is gone.
# Usage: wlc_keepalive.sh [INTERVAL_SEC]
set -u
cd "$(git rev-parse --show-toplevel)"
interval=${1:-120}
while :; do
  if [ -d tmp/wlc-batch.lock ]; then
    echo "$(date +%T) skip (batch running)"
  elif timeout 60 ruby misc/ssh_cli.rb -s "${WLC_SESSION:-wlc-01.venue}" run --timeout 30 'show time' >/dev/null 2>&1; then
    echo "$(date +%T) ok"
  else
    echo "$(date +%T) SESSION LOST"
    exit 1
  fi
  sleep "$interval"
done
