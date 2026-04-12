# https://github.com/sorah/bluetooth-getty

package 'bluetooth-getty' do
end

service 'bluetooth-getty.service' do
  action [:enable, :start]
end
