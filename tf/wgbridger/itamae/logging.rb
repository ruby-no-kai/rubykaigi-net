directory '/etc/systemd/journald.conf.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

file '/etc/systemd/journald.conf.d/ephemeral.conf' do
  content <<-EOF
[Journal]
Storage=volatile
RuntimeMaxUse=10M

  EOF

  owner 'root'
  group 'root'
  mode '0644'
end
