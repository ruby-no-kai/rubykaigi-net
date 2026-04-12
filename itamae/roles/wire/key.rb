include_cookbook 'tpm'

execute 'wg genkey' do
  command "touch /etc/wire.key; chmod 600 /etc/wire.key; wg genkey|sudo systemd-creds encrypt --name network.wireguard.private.default --with-key 'host+tpm2' - /etc/wire.key"
  not_if 'test -e /etc/wire.key'
end
