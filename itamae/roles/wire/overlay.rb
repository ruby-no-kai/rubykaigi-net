include_cookbook 'systemd-container'

execute 'mmdebstrap for overlay' do
  command <<~EOF
    set -xe
    mmdebstrap \
      --include=dbus,libpam-systemd,libnss-systemd,systemd,systemd-resolved,iproute2,iputils-ping,curl,wireguard-tools,tcpdump,nftables \
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

template '/var/lib/machines/overlay/etc/systemd/system/open-ddns.timer' do
  owner 'root'
  group 'root'
  mode '0644'
end

template '/var/lib/machines/overlay/etc/systemd/system/open-ddns.service' do
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

execute 'chroot /var/lib/machines/overlay systemctl enable open-ddns.timer' do
  not_if 'chroot /var/lib/machines/overlay systemctl is-enabled open-ddns.timer'
end

execute 'chroot /var/lib/machines/overlay systemctl enable open-ddns.service' do
  not_if 'chroot /var/lib/machines/overlay systemctl is-enabled open-ddns.service'
end

execute 'systemctl --machine overlay reload nftables' do
  action :nothing
end

template '/var/lib/machines/overlay/etc/nftables.conf' do
  owner 'root'
  group 'root'
  mode '0755'
  # notifies :run, 'execute[systemctl --machine overlay reload nftables]'
end

execute 'chroot /var/lib/machines/overlay systemctl enable nftables.service' do
  not_if 'chroot /var/lib/machines/overlay systemctl is-enabled nftables.service'
end


link '/var/lib/machines/overlay/etc/localtime' do
  to '/usr/share/zoneinfo/UTC'
  force true
end

execute 'echo -n | sudo systemd-creds encrypt --name open-ddns-key --with-key="host+tpm2" - /etc/open-ddns-key.key' do
  not_if 'test -e /etc/open-ddns-key.key'
end

service 'systemd-nspawn@overlay.service' do
  action [:enable, :start]
end
