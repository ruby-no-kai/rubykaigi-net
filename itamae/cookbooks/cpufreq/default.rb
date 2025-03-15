template '/etc/systemd/system/cpufreq.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'cpufreq.service' do
  action [:enable, :start]
end
