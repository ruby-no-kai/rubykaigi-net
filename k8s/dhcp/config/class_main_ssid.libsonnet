local consts = import './consts.libsonnet';
{
  name: 'main_ssid',
  test: "split(relay4[2].hex, ':', 2) == 'Kaigi on Rails 2025'",
  'only-if-required': true,
  'option-data': [
    {
      name: 'v6-only-preferred',
      data: '1800',
    },
  ],
}
