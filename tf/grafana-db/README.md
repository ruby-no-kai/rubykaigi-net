Apply this module before `tf/grafana`.

## DB initialization

Run on bastion:

```
mysql -urk -phimitsudayo -h grafana1.db.apne1.rubykaigi.net
```

```sql
 set password = '{rk user password}';
create user grafana@"%" identified by '{random password}';
grant all on grafana.* to grafana@"%";
flush privileges;
```

Create secret:

```
 ( umask 0066; echo -n '{password}' > /tmp/sec )
kubectl create secret generic grafana-mysql --from-literal=username=grafana --from-file=password=/tmp/sec
shred --remove /tmp/sec
```

Than apply `tf/grafana`.
