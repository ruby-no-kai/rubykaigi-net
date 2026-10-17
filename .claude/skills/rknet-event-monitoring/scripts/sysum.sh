#!/bin/sh
# usage: sysum.sh FILE [TOP=25] — syslog patterns minus known noise
# The second grep holds WLC client-handshake noise that runs at hundreds per round in a crowd; drop it to see those again.
grep -vE "glazed|UI_|mgd\[|sshd|cron|license-check|LIBJNX|SSH\[|GW\[|CNFG\[|ARP\[|DISC_AP_MGR|SCOPE_NOT_FOUND|RADIUS_OVERRIDE|USE_DEFAULT_CIPHER|MOBILESTATION_NOT_FOUND|SISF|Traceback|ACL\[|FLT\[|tun-01.itm|IKE2.*(itm|SA-INIT|Rekey|Delete|Child SA)|recon-01.*(BGP|IKE)|QOS_NAME|awsnat: Time-to-live|TCP\[.*cleanup|AAA_AUTH_ADMIN" "$1" |
  grep -viE 'ARP|MSCB|RADIUS_OVERRIDE|MOBILE_NOT_EXCLUDED|RSN_WARP|EAPOL|REPLAY|SAE_PEER|MGMT_DATA|DP_MSG' |
  cut -d' ' -f2- | sed -E 's/[0-9a-f]{2}(:[0-9a-f]{2}){5}/MAC/gI; s/[0-9]+/N/g' | cut -c1-180 | sort | uniq -c | sort -rn | head -"${2:-25}"
