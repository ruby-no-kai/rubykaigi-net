local consts = import './consts.libsonnet';
{
  name: 'pxe_ipxe',
  test: 'option[175].exists',
  'only-if-required': true,
  'option-data': [
    {
      name: 'tftp-server-name',
      data: consts.tftp_server,
    },
    {
      name: 'boot-file-name',
      data: 'https://tftp.rubykaigi.net/ro/compute/default.ipxe',
    },
    {
      name: 'log-servers',
      data: consts.syslog_server,
    },
  ],
}
