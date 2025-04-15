include_cookbook 'ruby'
package 'git'

directory '/opt/conntrack_exporter' do
  owner 'root'
  group 'root'
  mode '0755'
end

remote_file '/opt/conntrack_exporter/Gemfile' do
  owner 'root'
  group 'root'
  mode '0644'
end

remote_file '/opt/conntrack_exporter/Gemfile.lock' do
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'bundle install' do
  cwd '/opt/conntrack_exporter'
  command <<EOF
set -e
bundle config set --local deployment true
bundle install
(ruby -v && cat Gemfile.lock) | sha256sum >.bundle/hash
EOF
  not_if '(ruby -v && cat Gemfile.lock) | sha256sum -c .bundle/hash'
  notifies :restart, 'service[conntrack_exporter]'
end

remote_file '/etc/systemd/system/conntrack_exporter.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
  notifies :restart, 'service[conntrack_exporter]'
end

service 'conntrack_exporter' do
  action [:enable, :start]
end
