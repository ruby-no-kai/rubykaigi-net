include_cookbook 'ruby'
package 'git'

directory '/opt/xlat' do
  owner 'root'
  group 'root'
  mode '0755'
end

execute 'git clone xlat' do
  command %{git clone https://github.com/sorah/xlat /opt/xlat}
  not_if 'test -e /opt/xlat/.git'
end

execute 'git pull xlat' do
  git = 'git -C /opt/xlat'

  command %{#{git} reset --hard origin/main}
  only_if %{#{git} fetch origin && test "$(#{git} rev-parse HEAD)" != "$(#{git} rev-parse origin/main)"}
end

execute 'bundle install' do
  cwd '/opt/xlat'
  command <<EOF
set -e
bundle config set --local deployment true
bundle install
(ruby -v && git rev-parse HEAD) | sha256sum >.bundle/hash
bundle exec rake compile
EOF
  not_if '(ruby -v && git rev-parse HEAD) | sha256sum -c .bundle/hash'
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
