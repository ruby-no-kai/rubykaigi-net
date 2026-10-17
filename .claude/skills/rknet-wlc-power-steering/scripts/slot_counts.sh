#!/bin/sh
# 5 GHz (slot 1) client count per AP from `show client summary`, busiest first. Usage: slot_counts.sh [AP_REGEX] [TOP=15]
# Counts include ghost entries (Association Id 0), which show as Associated; compare with Prometheus when a count looks too high.
cd "$(git rev-parse --show-toplevel)"
timeout 60 ruby misc/ssh_cli.rb -s "${WLC_SESSION:-wlc-01.venue}" run 'show client summary' |
  awk -v re="${1:-.}" '/^[0-9a-f][0-9a-f]:/ && $3 == 1 && $2 ~ re { print $2 }' | sort | uniq -c | sort -rn | head -"${2:-15}"
