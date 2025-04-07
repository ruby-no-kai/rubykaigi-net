directory '/etc/xtables' do
  owner 'root'
  group 'root'
  mode '0755'
end

remote_file '/etc/xtables/connlabel.conf' do
  owner 'root'
  group 'root'
  mode '0644'
end

link '/etc/connlabel.conf' do
  to '/etc/xtables/connlabel.conf'
end
