local db_host = 'kea1.db.apne1.rubykaigi.net';
local db_name = 'kea';
{
  app_container:: {
    name: 'app',
    image: '005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/kea:02a8fc80e747a92083540960aab407f098ba0092',
    env: [
      { name: 'LEASE_DATABASE_NAME', value: db_name },
      { name: 'LEASE_DATABASE_HOST', value: db_host },
      { name: 'LEASE_DATABASE_USER', valueFrom: { secretKeyRef: { name: 'kea-mysql', key: 'username' } } },
      { name: 'LEASE_DATABASE_PASSWORD', valueFrom: { secretKeyRef: { name: 'kea-mysql', key: 'password' } } },
      { name: 'HOSTS_DATABASE_NAME', value: db_name },
      { name: 'HOSTS_DATABASE_HOST', value: db_host },
      { name: 'HOSTS_DATABASE_USER', valueFrom: { secretKeyRef: { name: 'kea-mysql', key: 'username' } } },
      { name: 'HOSTS_DATABASE_PASSWORD', valueFrom: { secretKeyRef: { name: 'kea-mysql', key: 'password' } } },

    ],
    volumeMounts: [
      { name: 'config', mountPath: '/config' },
      { name: 'server-ids', mountPath: '/server-ids' },
    ],
  },

  spec: {
    containers: [
      $.app_container,
    ],
    volumes: [
      { name: 'config', configMap: { name: 'kea-config', items: [{ key: 'kea-dhcp4.json', path: 'kea-dhcp4.json' }] } },
      { name: 'server-ids', configMap: { name: 'kea-server-ids', items: [{ key: 'server-ids.json', path: 'server-ids.json' }] } },
    ],
  },
}
