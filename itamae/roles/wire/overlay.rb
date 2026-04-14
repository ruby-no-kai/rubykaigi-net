include_cookbook 'systemd-container'

execute 'mmdebstrap for overlay' do
  command <<~EOF
    set -xe
    mmdebstrap \
      --include=dbus,libpam-systemd,libnss-systemd,systemd,systemd-resolved,iproute2,iputils-ping,curl,wireguard-tools \
      --dpkgopt='path-exclude=/usr/share/man/*' \
      --dpkgopt='path-include=/usr/share/man/man[1-9]/*' \
      --dpkgopt='path-exclude=/usr/share/locale/*' \
      --dpkgopt='path-include=/usr/share/locale/locale.alias' \
      --dpkgopt='path-exclude=/usr/share/doc/*' \
      --dpkgopt='path-include=/usr/share/doc/*/copyright' \
      --dpkgopt='path-include=/usr/share/doc/*/changelog.Debian.*' \
      --variant=essential "$(lsb_release -sc)" /root/overlay.tar
    importctl import-tar --class=machine /root/overlay.tar overlay
  EOF
  not_if 'test -e /var/lib/machines/overlay/etc/hostname'
end

template '/etc/systemd/nspawn/overlay.nspawn' do
  owner 'root'
  group 'root'
  mode '0644'
end

directory '/etc/systemd/system/systemd-nspawn@overlay.service.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/systemd/system/systemd-nspawn@overlay.service.d/dropin.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

directory '/var/lib/machines/overlay/etc/systemd/network' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/var/lib/machines/overlay/etc/systemd/network/00-overlay.network' do
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'chroot /var/lib/machines/overlay systemctl enable systemd-networkd.service' do
  not_if 'chroot /var/lib/machines/overlay systemctl is-enabled systemd-networkd.service'
end

execute 'chroot /var/lib/machines/overlay systemctl enable systemd-resolved.service' do
  not_if 'chroot /var/lib/machines/overlay systemctl is-enabled systemd-resolved.service'
end

execute 'chroot /var/lib/machines/overlay systemctl enable systemd-networkd-wait-online.service' do
  not_if 'chroot /var/lib/machines/overlay systemctl is-enabled systemd-networkd-wait-online.service'
end

execute 'chroot /var/lib/machines/overlay systemctl enable network-online.target' do
  not_if 'chroot /var/lib/machines/overlay systemctl is-enabled network-online.target'
end

service 'systemd-nspawn@overlay.service' do
  action [:enable, :start]
end
