local consts = import './consts.libsonnet';
{
  name: 'main_ssid',
  test: "(split(relay4[2].hex, ':', 2) == 'Kaigi on Rails 2025') or (relay4[1] == 'cs-01-venue:ge-0/0/0.0:usr')",
  'only-if-required': true,
  'option-data': [
    {
      name: 'v6-only-preferred',
      data: '1800',
    },
  ],
}
