local cloud_config = (import '../cloudconfig.base.libsonnet') + {
  bootcmd: [
    ['cloud-init-per', 'once', 'ssh-port', 'bash', '-c', 'echo Port 9922 >> /etc/ssh/sshd_config'],
  ],
  packages: [
    'iperf3',
    'mtr',
    'postgresql-client',
    'mysql-client',
    'screenfetch',
  ],
};

{
  cloud_config: cloud_config,
  user_data: std.format('#cloud-config\n%s\n', std.manifestYamlDoc(cloud_config)),
}
