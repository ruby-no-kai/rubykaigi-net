#!/bin/bash
# Usage: post_slack.sh WEBHOOK_URL_FILE < message.txt
#
# Posts stdin to a Slack incoming webhook whose URL is in WEBHOOK_URL_FILE, without
# printing the URL.
set -eu -o pipefail
url=$(tr -d '[:space:]' < "$1")
res=$(jq -Rs '{text: .}' | curl -sS -w ' http=%{http_code}' -X POST -H 'Content-Type: application/json' --data @- "$url")
echo "$res"
[[ $res == 'ok http=200' ]]
