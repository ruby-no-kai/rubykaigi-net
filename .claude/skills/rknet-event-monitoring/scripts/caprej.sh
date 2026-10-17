#!/bin/sh
# usage: caprej.sh FILE — per-radio client-cap rejects per minute in a syslog.sh output file (the line names no AP)
grep 'Maximum Client Limit Reached' "$1" | awk '{ print substr($1, 1, 5) }' | uniq -c | awk '{ printf "%s=%s ", $2, $1; n += $1 } END { print "total=" n + 0 }'
