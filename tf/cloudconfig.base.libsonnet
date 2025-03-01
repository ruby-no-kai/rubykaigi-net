{
  users: [
    {
      name: 'rk',
      primary_group: 'rk',
      uid: 3333,
      groups: 'adm,sudo,plugdev,netdev,lxd',
      ssh_import_id: import '../data/ssh_import_ids.json',
      sudo: 'ALL=(ALL) NOPASSWD: ALL',
      shell: '/bin/bash',
    },
  ],
}
