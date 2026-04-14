package 'systemd-container'
package 'mmdebstrap'

directory '/var/lib/machines' do
  owner 'root'
  group 'root'
  mode '0700'
end

directory '/etc/systemd/nspawn' do
  owner 'root'
  group 'root'
  mode '0755'
end
