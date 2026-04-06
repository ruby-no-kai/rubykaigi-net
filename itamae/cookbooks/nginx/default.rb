package 'nginx'

service 'nginx.service' do
  action [:enable, :start]
end

execute 'nginx -s reload' do
  action :nothing
end
