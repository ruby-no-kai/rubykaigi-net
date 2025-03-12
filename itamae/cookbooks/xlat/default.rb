include_cookbook 'ruby'
package 'git'

# migration
execute 'rm -rf /opt/xlat' do
  only_if 'test -e /opt/xlat/.git'
end

directory '/opt/xlat' do
  owner 'root'
  group 'root'
  mode '0755'
end

remote_file '/opt/xlat/Gemfile' do
  owner 'root'
  group 'root'
  mode '0644'
end

remote_file '/opt/xlat/Gemfile.lock' do
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'bundle install' do
  cwd '/opt/xlat'
  command <<EOF
set -e
bundle config set --local deployment true
bundle install
(ruby -v && cat Gemfile.lock) | sha256sum >.bundle/hash
EOF
  not_if '(ruby -v && cat Gemfile.lock) | sha256sum -c .bundle/hash'
end

remote_file '/etc/systemd/system/xlat-siit.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'xlat-siit' do
  action [:enable, :start]
end
