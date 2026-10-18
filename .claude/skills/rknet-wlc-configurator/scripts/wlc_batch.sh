#!/bin/sh
# Runs a pre-approved wlc-01 change set from a file and prints a JST timestamp before each command for the monitor.
# Usage: wlc_batch.sh FILE
# FILE: one command per line; `# ...` lines are comments, `== text` prints a marker,
# `! CMD` sends a command that asks (y/n) and answers y (also `! save config`), `? CMD | REGEX` runs a show command
# and keeps only matching lines. Stops at the first error the WLC reports; rerun a regenerated file to continue.
set -u
[ $# -eq 1 ] || { echo "usage: $0 FILE" >&2; exit 64; }
file=$(realpath "$1")
cd "$(git rev-parse --show-toplevel)"
cli() { timeout 150 ruby misc/ssh_cli.rb -s "${WLC_SESSION:-wlc-01.venue}" "$@"; }
stamp() { TZ=Asia/Tokyo date +%T; }
ERRORS='rror|ncorrect|nvalid|not found|ailed|denied|Canceled|not changed'
check() { out=$(cat); [ -n "$out" ] && printf '%s\n' "$out"; ! printf '%s\n' "$out" | grep -qE "$ERRORS"; }
die() { echo "$(stamp) ABORT: $*" >&2; exit 1; }

# wlc_keepalive.sh must not type into a (y/n) question.
lock=tmp/wlc-batch.lock
mkdir -p tmp
mkdir "$lock" 2>/dev/null || die "another batch is running ($lock)"
trap 'rmdir "$lock"' EXIT

# Reuse the open session: a new login signs at bastion again, which can't be answered while the Mac is locked.
if ! cli run --timeout 20 'show time' >/dev/null 2>&1; then
  cli close >/dev/null 2>&1
  cli open --dialect aireos --idle-timeout 0 wlc-01.venue.rubykaigi.net || die "cannot open the WLC session"
fi

while IFS= read -r line; do
  case $line in
    ''|'#'*) ;;
    '== '*) echo "$line" ;;
    '! '*)
      echo "$(stamp) > ${line#! }"
      # ssh_cli does not recognise AireOS's (y/n), so the command times out at the question; the y returns the prompt.
      cli send --timeout 10 "${line#! }" | grep -E 'reboot|sure|save|rror|nvalid' | check || die "${line#! }"
      cli send --timeout 120 'y' | grep -vE '^\s*$|^y$|Cisco Controller' | check || die "${line#! } (after y)" ;;
    '? '*)
      cmd=${line#? }
      echo "$(stamp) > ${cmd%% | *}"
      cli run --timeout 50 "${cmd%% | *}" | grep -E "${cmd#* | }" ;;
    *)
      echo "$(stamp) > $line"
      cli run --timeout 50 "$line" | check || die "$line" ;;
  esac
done < "$file"
echo "$(stamp) done"
