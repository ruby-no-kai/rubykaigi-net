{
  users: [
    {
      name: 'rk',
      primary_group: 'rk',
      uid: 3333,
      groups: 'adm,sudo,plugdev,netdev,lxd',
      ssh_authorized_keys: ['# dummy comment'],
      sudo: 'ALL=(ALL) NOPASSWD: ALL',
      shell: '/bin/bash',
    },
  ],

  runcmd_get_authorized_keys:: [
    ['curl', '-o', '/home/rk/.ssh/authorized_keys.rknet', 'https://rubykaigi.net/authorized_keys'],  // //tf/bastion/ssh_keys.tf
    ['bash', '-c', 'cat /home/rk/.ssh/authorized_keys.rknet | tee -a /home/rk/.ssh/authorized_keys'],
    ['rm', '/home/rk/.ssh/authorized_keys.rknet'],
    ['ls', '-la', '/home/rk/.ssh'],
  ],

  runcmd: [] +
          $.runcmd_get_authorized_keys,
}
