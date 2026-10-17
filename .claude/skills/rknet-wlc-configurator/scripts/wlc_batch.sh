#!/bin/sh
# Runs a pre-approved wlc-01 change set from a file and prints a JST timestamp before each command for the monitor.
# Usage: wlc_batch.sh FILE
# FILE: one command per line; `# ...` lines are comments, `== text` prints a marker,
# `! CMD` sends a command that asks (y/n) and answers y, `? CMD | REGEX` runs a show command and keeps only matching lines.
set -u
[ $# -eq 1 ] || { echo "usage: $0 FILE" >&2; exit 64; }
file=$(realpath "$1")
cd "$(git rev-parse --show-toplevel)"
cli() { timeout 60 ruby misc/ssh_cli.rb -s "${WLC_SESSION:-wlc-01.venue}" "$@"; }
stamp() { TZ=Asia/Tokyo date +%T; }

cli close >/dev/null 2>&1
cli open --dialect aireos --idle-timeout 0 wlc-01.venue.rubykaigi.net || exit 1

while IFS= read -r line; do
  case $line in
    ''|'#'*) ;;
    '== '*) echo "$line" ;;
    '! '*)
      echo "$(stamp) > ${line#! }"
      # The first prompt can time out in ssh_cli while the y still applies; verify afterwards.
      cli send --timeout 10 "${line#! }" | grep -E 'reboot|sure|rror|nvalid' || true
      cli send --timeout 15 'y' | grep -vE '^\s*$|^y$|Cisco Controller' || true ;;
    '? '*)
      cmd=${line#? }
      echo "$(stamp) > ${cmd%% | *}"
      cli run --timeout 50 "${cmd%% | *}" | grep -E "${cmd#* | }" ;;
    *)
      echo "$(stamp) > $line"
      cli run --timeout 50 "$line" ;;
  esac
done < "$file"
echo "$(stamp) done"
