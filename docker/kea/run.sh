#!/usr/bin/dumb-init /bin/bash
mkdir /work
cd /work

SERVER_ID=$(/app/choose_dhcp_server_id.rb)
if [ -z "${SERVER_ID}" ]; then
  if grep -q __SERVER_ID__ /config/kea-dhcp4.json; then
    echo "Failed to choose server id"
    exit 1
  fi
fi
echo "SERVER_ID=${SERVER_ID}"

(
  umask 077
  sed \
    -e "s|__LEASE_DATABASE_NAME__|${LEASE_DATABASE_NAME}|g" \
    -e "s|__LEASE_DATABASE_HOST__|${LEASE_DATABASE_HOST}|g" \
    -e "s|__LEASE_DATABASE_USER__|${LEASE_DATABASE_USER}|g" \
    -e "s|__LEASE_DATABASE_PASSWORD__|${LEASE_DATABASE_PASSWORD}|g" \
    -e "s|__HOSTS_DATABASE_NAME__|${HOSTS_DATABASE_NAME}|g" \
    -e "s|__HOSTS_DATABASE_HOST__|${HOSTS_DATABASE_HOST}|g" \
    -e "s|__HOSTS_DATABASE_USER__|${HOSTS_DATABASE_USER}|g" \
    -e "s|__HOSTS_DATABASE_PASSWORD__|${HOSTS_DATABASE_PASSWORD}|g" \
    -e "s|__SERVER_ID__|${SERVER_ID}|g" \
    /config/kea-dhcp4.json > /work/kea-dhcp4.json
)

kea-ctrl-agent -c /app/kea-ctrl-agent.json &
stork-agent &

kea-dhcp4 -c /work/kea-dhcp4.json
