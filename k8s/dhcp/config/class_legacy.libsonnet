local consts = import './consts.libsonnet';
{
  name: 'legacy',
  test: "split(relay4[2].hex, ':', 2) == 'RubyKaigi 2025 Legacy'",
  'only-if-required': true,
  'option-data': [
    {
      name: 'v6-only-preferred',
      data: '0',
    },
  ],
}
