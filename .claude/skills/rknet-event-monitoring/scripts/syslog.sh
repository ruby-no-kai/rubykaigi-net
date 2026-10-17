#!/bin/sh
# usage: syslog.sh SINCE_EPOCH OUTFILE   (LOG_GROUP env overrides the year-specific default; read it from k8s/syslog/config/fluent.conf)
aws logs filter-log-events --region ap-northeast-1 --log-group-name "${LOG_GROUP:-/rk26net/syslog}" --start-time $(( $1 * 1000 )) --query 'events[].[timestamp,logStreamName,message]' --output text | python3 -c 'import sys,json,datetime
for l in sys.stdin:
  p=l.rstrip("\n").split("\t",2)
  if len(p)<3: continue
  t=datetime.datetime.fromtimestamp(int(p[0])/1000, datetime.timezone(datetime.timedelta(hours=9))).strftime("%H:%M:%S")
  h=p[1].replace(".rubykaigi.net","")
  try: m=json.loads(p[2]); print(t,h,m.get("severity"),m.get("message")[:300])
  except Exception: print(t,h,"?",p[2][:300])' > $2
