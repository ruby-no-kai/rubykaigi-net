local consts = import './consts.libsonnet';
{
  name: 'main_ssid',
  test: "not match('.*Legacy', split(relay4[2].hex, ':', 2))",
  'only-if-required': true,
  'option-data': [
    {
      name: 'v6-only-preferred',
      data: '1800',
    },
  ],
}
