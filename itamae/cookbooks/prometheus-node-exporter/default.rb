node.reverse_merge!(
  prometheus: {
    node_exporter: {
      systemd_unit_whitelist: ['sshd?.service', 'sssd.service'],
      collectors: %w(
        bonding
        conntrack
        cpu
        cpufreq
        diskstats
        entropy
        filefd
        filesystem
        hwmon
        loadavg
        logind
        mdadm
        meminfo
        netclass
        netdev
        netstat
        nfs
        nfsd
        sockstat
        stat
        systemd
        textfile
        time
        uname
        vmstat
        zfs
        ipvs
      )
    },
  },
)

package 'prometheus-node-exporter'

user 'node_exporter' do
  system_user true
end

directory '/var/lib/prometheus-node-exporter' do
  owner 'root'
  group 'root'
  mode  '0755'
end
directory '/var/lib/prometheus-node-exporter/textfile_collector' do
  owner 'root'
  group 'root'
  mode  '0755'
end

template '/etc/systemd/system/prometheus-node-exporter.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
  notifies :restart, 'service[prometheus-node-exporter.service]', :immediately
end

service 'prometheus-node-exporter.service' do
  action [:enable, :start]
end
