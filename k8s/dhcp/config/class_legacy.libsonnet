local consts = import './consts.libsonnet';
{
  name: 'legacy',
  test: "split(option[82].option[2].text, ':', 2) == 'RubyKaigi 2025 Legacy'",
  'only-if-required': true,
  'option-data': [
    {
      name: 'v6-only-preferred',
      data: '0',
    },
  ],
}
