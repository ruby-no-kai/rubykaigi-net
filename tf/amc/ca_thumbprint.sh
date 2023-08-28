#!/bin/bash -e

# verify the target is legit
#curl -Ssf -o /dev/null https://${1}:443

thumbprint="$(echo | openssl s_client -servername $1 -showcerts -connect ${1}:443 2> /dev/null \
     | sed -n -e '/BEGIN/h' -e '/BEGIN/,/END/H' -e '$x' -e '$p' | tail +2 \
     | openssl x509 -fingerprint -noout \
     | sed -e "s/.*=//" -e "s/://g" \
     | tr "ABCDEF" "abcdef")"

echo "{\"thumbprint\":\"${thumbprint}\"}"
