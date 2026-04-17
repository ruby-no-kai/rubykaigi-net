include_cookbook 'systemd-container'

execute 'stop and mask systemd-nspawn@overlay.service' do
  command 'systemctl stop systemd-nspawn@overlay.service && systemctl mask systemd-nspawn@overlay.service'
  only_if 'test -e /var/lib/machines/overlay && test "$(systemctl is-enabled systemd-nspawn@overlay.service)" != masked'
end

execute 'mmdebstrap for underlay' do
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
      --variant=essential "$(lsb_release -sc)" /root/underlay.tar
    importctl import-tar --class=machine /root/underlay.tar underlay
  EOF
  not_if 'test -e /var/lib/machines/underlay/etc/hostname'
end

template '/etc/systemd/nspawn/underlay.nspawn' do
  owner 'root'
  group 'root'
  mode '0644'
end

directory '/etc/systemd/system/systemd-nspawn@underlay.service.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/systemd/system/systemd-nspawn@underlay.service.d/dropin.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

directory '/var/lib/machines/underlay/etc/systemd/network' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/var/lib/machines/underlay/etc/systemd/network/00-underlay.network' do
  owner 'root'
  group 'root'
  mode '0644'
end

template '/var/lib/machines/underlay/etc/systemd/system/open-ddns.timer' do
  owner 'root'
  group 'root'
  mode '0644'
end

template '/var/lib/machines/underlay/etc/systemd/system/open-ddns.service' do
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'chroot /var/lib/machines/underlay systemctl enable systemd-networkd.service' do
  not_if 'chroot /var/lib/machines/underlay systemctl is-enabled systemd-networkd.service'
end

execute 'chroot /var/lib/machines/underlay systemctl enable systemd-resolved.service' do
  not_if 'chroot /var/lib/machines/underlay systemctl is-enabled systemd-resolved.service'
end

execute 'chroot /var/lib/machines/underlay systemctl enable systemd-networkd-wait-online.service' do
  not_if 'chroot /var/lib/machines/underlay systemctl is-enabled systemd-networkd-wait-online.service'
end

execute 'chroot /var/lib/machines/underlay systemctl enable network-online.target' do
  not_if 'chroot /var/lib/machines/underlay systemctl is-enabled network-online.target'
end

execute 'chroot /var/lib/machines/underlay systemctl enable open-ddns.timer' do
  not_if 'chroot /var/lib/machines/underlay systemctl is-enabled open-ddns.timer'
end

execute 'chroot /var/lib/machines/underlay systemctl enable open-ddns.service' do
  not_if 'chroot /var/lib/machines/underlay systemctl is-enabled open-ddns.service'
end

execute 'systemctl --machine underlay reload nftables' do
  action :nothing
end

template '/var/lib/machines/underlay/etc/nftables.conf' do
  owner 'root'
  group 'root'
  mode '0755'
  # notifies :run, 'execute[systemctl --machine underlay reload nftables]'
end

execute 'chroot /var/lib/machines/underlay systemctl enable nftables.service' do
  not_if 'chroot /var/lib/machines/underlay systemctl is-enabled nftables.service'
end


link '/var/lib/machines/underlay/etc/localtime' do
  to '/usr/share/zoneinfo/UTC'
  force true
end

execute 'echo -n | sudo systemd-creds encrypt --name open-ddns-key --with-key="host+tpm2" - /etc/open-ddns-key.key' do
  not_if 'test -e /etc/open-ddns-key.key'
end

service 'systemd-nspawn@underlay.service' do
  action [:enable, :start]
end
