local consts = import './consts.libsonnet';
local domainName = 'test.tkyk.rubykaigi.net';
{
  id: 931,
  subnet: '10.33.31.0/24',
  pools: [
    {
      pool: '10.33.31.200 - 10.33.31.250',
    },
  ],
  'option-data': [
    {
      name: 'routers',
      data: '10.33.31.254',
    },
    {
      name: 'domain-name',
      data: domainName,
    },
    {
      name: 'domain-search',
      data: std.join(', ', [domainName, 'venue.rubykaigi.net'] + consts.search_domains),
    },
  ],
}
