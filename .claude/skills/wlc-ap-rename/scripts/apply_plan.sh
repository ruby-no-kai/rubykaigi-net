#!/bin/bash
# Usage: apply_plan.sh PLAN_FILE [--dry-run]
#
# Runs each `config ap name <new> <old>` line of PLAN_FILE on the open ssh_cli session
# (WLC_SESSION, default wlc-01.venue), saves the configuration and checks the new names
# in `show ap summary`. Stops at the first anomaly with exit 1. Does not open sessions.
set -u -o pipefail

repo=$(cd "$(dirname "$0")" && git rev-parse --show-toplevel)
plan=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
dry=${2:-}
sess=${WLC_SESSION:-wlc-01.venue}
cli() { ruby "$repo/misc/ssh_cli.rb" -s "$sess" "$@"; }
die() { echo "ABORT: $*" >&2; exit 1; }

[[ -s $plan ]] || die "plan file empty: $plan"
grep -v -E '^config ap name \S+ \S+$' "$plan" && die "unexpected line in $plan"

# keepalive.sh must not type into the (y/n) prompt of save config.
lock=$repo/tmp/ap-rename/wlc.lock
mkdir -p "$(dirname "$lock")"
mkdir "$lock" 2>/dev/null || die "another apply_plan is running ($lock)"
trap 'rmdir "$lock"' EXIT

summary=$(cli run 'show ap summary') || die "no session $sess; open it with the ssh-cli skill"
# APs already carrying the new name are skipped, so a slot that stopped midway can be run again.
pending=()
while read -r line; do
  read -r _ _ _ new old <<<"$line"
  if grep -q "^$old " <<<"$summary"; then
    pending+=("$line")
  elif grep -q "^$new " <<<"$summary"; then
    echo "skip $old -> $new (already renamed)"
  else
    die "neither $old nor $new is on WLC (unplugged?)"
  fi
done < "$plan"

if [[ $dry == --dry-run ]]; then
  echo "dry-run ok: ${#pending[@]} to rename, $(( $(wc -l < "$plan") - ${#pending[@]} )) already renamed"
  exit 0
fi

# Saving runs even when nothing is pending, for a slot that stopped before save config.
for line in ${pending[@]+"${pending[@]}"}; do
  echo ">> $line"
  out=$(cli run --timeout 30 "$line") || die "timed out or session lost on: $line / output: $out"
  [[ -n $out ]] && echo "$out"
  grep -qiE 'error|incorrect|invalid|not found|fail|denied' <<<"$out" && die "device reported an error on: $line"
done

# ssh_cli does not recognise AireOS's (y/n), so the first send times out at the question.
echo ">> save config"
out=$(cli send --timeout 10 'save config')
grep -q '(y/n)' <<<"$out" || die "save config did not ask (y/n): $out"
out=$(cli send --no-newline --timeout 120 y) || die "save config did not return to the prompt: $out"
grep -q 'Configuration Saved' <<<"$out" || die "save config did not confirm: $out"
echo "saved"

summary=$(cli run 'show ap summary') || die "show ap summary failed after rename"
ng=0
while read -r _ _ _ new old; do
  if grep -q "^$new " <<<"$summary"; then echo "ok  $old -> $new"; else echo "NG  $old -> $new"; ng=1; fi
done < "$plan"
[[ $ng == 0 ]] || die "some APs do not show the new name yet"
echo "DONE $plan"
