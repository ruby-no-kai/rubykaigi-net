#!/bin/bash
set -eu

cd "$(mktemp -d)"

cat > mib-dump.json
exec trapbridge mib-dump --config mib-dump.json "$@"
