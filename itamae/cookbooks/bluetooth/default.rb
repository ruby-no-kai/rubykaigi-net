package 'bluez' do
end

service 'bluetooth.service' do
  action [:enable, :start]
end
