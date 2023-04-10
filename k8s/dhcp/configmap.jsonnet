local consts = import './config/consts.libsonnet';
local config = {
  Dhcp4: {
    'interfaces-config': {
      interfaces: ['*'],
      'dhcp-socket-type': 'udp',  // unicast only
    },

    'lease-database': {
      type: 'mysql',
      name: 'kea',
      host: 'kea1.db.apne1.rubykaigi.net',
      user: '__LEASE_DATABASE_USER__',
      password: '__LEASE_DATABASE_PASSWORD__',
      'connect-timeout': 10,
      'max-reconnect-tries': 5,
      'reconnect-wait-time': 2000,
    },

    //'hosts-database': {
    //  readonly: true,
    //  type: 'mysql',
    //  name: 'kea',
    //  host: 'kea1.db.apne1.rubykaigi.net',
    //  user: '__HOSTS_DATABASE_USER__',
    //  password: '__HOSTS_DATABASE_PASSWORD__',
    //  'connect-timeout': 10,
    //  'max-reconnect-tries': 5,
    //  'reconnect-wait-time': 2000,
    //},

    'control-socket': {
      'socket-type': 'unix',
      'socket-name': '/run/kea/dhcp4.sock',
    },

    loggers: [
      {
        name: name,
        severity: 'INFO',
        output_options: [{ output: 'stdout' }],
      }
      for name in [
        'kea-dhcp4',
        'kea-dhcp4.alloc-engine',
        'kea-dhcp4.database',
        'kea-dhcp4.hosts',
        'kea-dhcp4.leases',
      ]
    ] + [
      {
        name: 'kea-dhcp4.commands',
        severity: 'WARN',
        output_options: [{ output: 'stdout' }],
      },
    ],

    'valid-lifetime': 1200,
    'max-valid-lifetime': 3600,

    'expired-leases-processing': {
      'reclaim-timer-wait-time': 10,
      'flush-reclaimed-timer-wait-time': 25,
      'hold-reclaimed-time': 3600 * 15,
      'max-reclaim-leases': 100,
      'max-reclaim-time': 250,
      'unwarned-reclaim-cycles': 5,
    },


    'option-data': [
      {
        name: 'domain-name-servers',
        data: std.join(', ', consts.dns_resolvers),
      },
      {
        name: 'ntp-servers',
        data: std.join(', ', consts.ntp_servers),
      },
      {
        name: 'domain-search',
        data: std.join(', ', consts.search_domains),
      },
      // {
      //   name: 'dhcp-server-identifier',
      //   data: '__SERVER_ID__',
      // },
    ],

    subnet4: [
      import './config/subnet_air.libsonnet',
      import './config/subnet_life.libsonnet',
      import './config/subnet_usr.libsonnet',
      import './config/subnet_cast.libsonnet',
      import './config/subnet_mgmt.libsonnet',
      import './config/subnet_tkyk.libsonnet',
      import './config/subnet_tkykmgmt.libsonnet',
    ],
  },
};

{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'kea-config',
    namespace: 'default',
  },
  data: {
    'kea-dhcp4.json': std.manifestJsonEx(config, '  '),
  },
}
