#!/bin/bash
set -eu -o pipefail

if [[ ${1:-} = /* ]]; then
    exec "$@"
fi

conffile=/etc/unbound/unbound.conf
for i in $(seq 1 $(( $# - 1 ))); do
    if [[ ${!i} = -c ]]; then
        : $(( ++i ))
        conffile="${!i}"
        break
    fi
done

echo "conffile: $conffile"
echo ====
cat "$conffile"
echo ====

sock=$(unbound-checkconf -o control-interface "$conffile")
if [[ $sock != /* ]]; then
    echo "control-interface is expected to be an absolute path: $sock" >&2
    exit 1
fi

/usr/local/bin/unbound_exporter --unbound.host "unix://$sock" &
/usr/sbin/unbound "$@"
