package 'nftables'

execute 'nft -f /etc/nftables.conf' do
  action :nothing
end

file '/etc/nftables.conf' do
  content <<-EOF
#!/usr/bin/nft -f
# vim: ft=nftables ts=2 sw=2
flush ruleset

table inet filter {
  chain output {
    type filter hook output priority 0;
    oifname "eth0" ip6 dscp set 0;
    oifname "br0" ip6 dscp set 0;
    accept
  }
  chain postrouting {
    type filter hook postrouting priority 0;
    oifname "eth0" ip6 dscp set 0;
    oifname "br0" ip6 dscp set 0;
    accept
  }
}
  EOF
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[nft -f /etc/nftables.conf]'
end

service 'nftables' do
  action [:enable, :start]
end
