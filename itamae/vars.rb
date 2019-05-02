node.reverse_merge!(
  ssh: {
    port: [22],
  },
)
node[:op_user_name] = 'rk'
node[:orgname] = 'rk'
node[:site_domain] = 'nw.rubykaigi.org'
node[:site_rdomain] = '33.10.in-addr.arpa'
node[:site_cidr] = '10.33.0.0/16'
node[:site_admin_domain] = "s.#{node.fetch(:site_domain)}"
# node[:site_cidr6] = ''

node[:use_nftables] = false

node[:wlc_host] = "wlc-01.venue.#{node.fetch(:site_domain)}"
node[:prometheus_host] = "prometheus-001.aws.#{node.fetch(:site_domain)}"
node[:grafana_host] = node[:prometheus_host]
node[:syslog_host] = "syslog-001.aws.#{node.fetch(:site_domain)}"
node[:upstream_dns] = %w(10.33.128.2)
node[:dns_servers] = %w(10.33.146.212 10.33.133.123)

node[:snmp_community] = 'public'

node[:extra_disk] = "/dev/nvme0n1"

node[:rproxy_htpasswd] = node[:secrets][:rproxy_htpasswd]
node[:default_authorized_keys] = [
  # sorah
  *"
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBADLFfXAbYvLbd3gTH08FfYEADFWVaa2xoHC4pzMNy+MoPbf9qPWTLGYlkXPL7QxgZH6dRk458rkfwEIySxajdIr0AEGcrvVTezzhYNvZReISWMBlO68cDprusADqLqoLus2booss4LIKmm6BI4vuuXtOOVhAdltj0gf/CVlpNuZ99szFw== americano2016ecdsa
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACG1cKNR8SS4Dkm2wcia74RRmy9d7h62114MQd0H9zb1+1LxVa55Qqd8O232BH1i/fF/1o+eE3L5U7RCR8KUCuAXgFrF429BETaiiBnSErv5yrHJS5RTTjEhA1d9Ygk0o3Und6+90waBXAk2oPVP+OBNtYq1CraZQsXuqvlUtMrBnSTsQ== sorah-mulberry-ecdsa
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAF6LlpYSW3SrzjQcZYifI0JYJlUpj5myp/20h7/HxL8aImwU9pBSPch9NH2QL8RB/G5MlaZ1P52Kg4bVueJCwVoPABIEDx/u1ilSS+03UJW6Yfh3a7VT/iuudlFyUPY2x9M4Cf/JgXCaCV7Yb/f4JaCjulGXKbzzHx58EIcqNxbp64Jug== sorah-w1-my-ecdsa
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnY8uGqMVviIttNHiz1M5MV5jL3GSt3nGWPxEErmEbaORQabn1UvBennzi87E4ZXa6wT9ZcfmvcrcckW6xiopU0A8CJSQAvKtpOB4eSFJkblELrmUpmxuDo5pHLpunpHHay2or8yPaLnwSfBnuyA7Lq2Cj1pw0LKq88Lda76ihWPWb7DfBVzedVYPKKunIk/4Wwj120ILOcoYI0r0XWiaxx9d3IvNvXroR7qqiKKZMacBpUWCwT3iX6GB0jhSRIJ1Do9qDyp/Sx4wyj4SxXasni5pqg/8ARwCkiMrbkAaedRRvP4umxuhBRc4VzqeWTvj5dPlkguwt1avbg3g/IDuO7/iJSEASN2H7qJEhH5rL5Aq1HCkOHGdlibdsFLNiCoOGKMNRO4mPsAkyf4i/kURP+a50+lRVlQSGGzFR5FFFcR0P83E+BkS/UkxC9MVGkvidLSmto/UkGqCfdLP6RJQMH6W54KMQ1epjWiLvW9FkspRha73lfxh7pC+jACRmL0E= sorah-w2-my
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAHoLUkgSzQfIXMx7nS9TzgFubVwYBiaWYPh2Ges30IMytU8oQyrQ4V/mPjvWHrij9pz0Uz+tbhR1+Tza85LzyFiCwDrZDQNqLGB7b/bwhy9cGQPVGUdiObJ4f2MEPYzyueEtmCQuh1NiPl/p8HSIyEBOmc19duWfKyvDRvayg8hJAs4mg== sorah-wD-my-ecdsa
  ".lines.map(&:strip).reject(&:empty?),
]

host_lines = File.read(File.join(node.fetch(:basedir), 'hosts.txt'))

node[:hosts_data] = host_lines.lines.
  map { |l| dc, network, cidr, ip, name, iface, mac = l.chomp.split(?\t, 7);{dc: dc, network: network, cidr: cidr, ip: ip, name: name, mac: (mac && !mac.empty? && mac != '#N/A') ? mac : nil, iface: (iface && !iface.empty?) ? iface : nil} }.
  reject { |_| _[:ip].nil? || _[:ip].empty? }.
  group_by { |_| [_[:dc], _[:name]] }.
  map { |_, ips| [ips[0].merge(primary: true), ips[1..-1]].flatten }.
  flatten

node[:network_tester] ||= [
  {host: '8.8.8.8'},
  {host: '1.1.1.1'},
]

node.reverse_merge!(
  rproxy: {
    tls: false,
  },
  prometheus: {
    alertmanager: {
      slack_url: 'https://hooks.slack.com/services/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',
    },
    snmp_hosts: [
      *node.fetch(:hosts_data).select{ |_| _[:primary] }.reject { |_| _[:dc] == 'ptp' }.map { |_| ["#{_.fetch(:name)}.c.#{node[:site_domain]}", %w(if_mib)] }.reject {|_| _[0].match?(/rt-01/) },
      [node[:wlc_host], %w(cisco_wlc)],
    ],
    snmp_lo_hosts: [
      *node.fetch(:hosts_data).select{ |_| _[:primary] }.reject { |_| _[:dc] == 'ptp' }.map { |_| ["#{_.fetch(:name)}.c.#{node[:site_domain]}", %w(if_mib)] }.select {|_| _[0].match?(/rt-01/) },
    ],
  },
  kea: {
    dns: node[:dns_servers],
    subnets: {
      air: {
        id: 102,
        subnet: '10.33.2.0/24',
        pools: %w(10.33.2.10-10.33.2.254),
        router: '10.33.2.1',
        domain: 'venue.nw.rubykaigi.org',
      },
      usr: {
        id: 164,
        subnet: '10.33.64.0/20',
        pools: %w(10.33.65.0-10.33.79.254),
        router: '10.33.64.1',
      },
      life: {
        id: 101,
        subnet: '10.33.1.0/24',
        pools: %w(10.33.1.50-10.33.1.254),
        router: '10.33.1.1',
      },
      sunaba: {
        id: 3200,
        subnet: '133.152.9.0/24',
        pools: %w(133.152.9.10-133.152.9.254),
        router: '133.152.9.1',
        dns: %w(8.8.8.8 8.8.4.4),
      },
    },
  }
)
