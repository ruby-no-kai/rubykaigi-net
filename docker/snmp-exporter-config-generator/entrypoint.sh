#!/bin/bash
set -eu

cd "$(mktemp -d)"

cat > generator.yml
/opt/snmp-exporter/bin/generator "$@"
cat snmp.yml
