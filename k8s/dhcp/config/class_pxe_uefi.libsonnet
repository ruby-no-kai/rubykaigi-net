local consts = import './consts.libsonnet';
{
  name: 'pxe_uefi',
  test: 'option[93].hex == 0x0007 and not option[175].exists',
  'only-if-required': true,
  'option-data': [
    {
      name: 'tftp-server-name',
      data: consts.tftp_server,
    },
    {
      name: 'boot-file-name',
      data: 'ro/compute/ipxe.efi',
    },
  ],
}
