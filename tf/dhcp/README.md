# kea deployment

## Setup

Run on bastion.

https://github.com/isc-projects/kea/blob/Kea-2.0.1/src/share/database/scripts/mysql/dhcpdb_create.mysql

```
sudo apt install -y mysql-client
mysql -urk -phimitsudayo -h kea1.db.apne1.rubykaigi.net
```

```sql
 set password = '{rk user password}';
create user kea@"%" identified by '{random password}';
grant all on kea.* to kea@"%";
flush privileges;
```

```
curl -LOf https://raw.githubusercontent.com/isc-projects/kea/Kea-2.0.1/src/share/database/scripts/mysql/dhcpdb_create.mysql
mysql -urk -p -h kea1.db.apne1.rubykaigi.net kea < dhcpdb_create.mysql
```

Create secret;

```
 ( umask 0066; echo -n '{password}' > /tmp/sec )
kubectl create secret generic kea-mysql --from-literal=username=kea --from-file=password=/tmp/sec
shred --remove /tmp/sec
```

Deploy

```
./gen-k8s.rb && kustomize build gen/k8s/dhcp | kubectl apply -f-
```
