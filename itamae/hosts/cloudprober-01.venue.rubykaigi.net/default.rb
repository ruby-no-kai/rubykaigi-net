node.reverse_merge!(
  systemd_networkd: {
    migrate_netplan: false,
  },
  cloudprober: {
    interfaces: {
      management: {
        name: 'enp1s0',
        duid: '00:00:ba:2c:33:09:c1',
      },
    },
  },
  wifi_workbench: {
    interface: 'wlp2s0',
    namespace: 'wifi-workbench',
  },
)

include_role 'cloudprober'

include_cookbook 'bluetooth-getty'
include_role 'wifi-workbench'
