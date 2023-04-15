#!/bin/bash -xe
RADIUS_SECRET=${RADIUS_SECRET:-testing123}
sed -i -e "s/__RADIUS_SECRET__/${RADIUS_SECRET}/g" /etc/freeradius/3.0/clients.conf
if [[ "${RADIUS_DEBUG}" = "1" ]];then
  isdebug=-xx
else
  isdebug=
fi
exec /usr/sbin/freeradius $isdebug -f -lstdout
