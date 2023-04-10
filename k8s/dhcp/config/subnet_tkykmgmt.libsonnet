local consts = import './consts.libsonnet';
local domainName = 'mgmt.tkyk.rubykaigi.net';
{
  id: 930,
  subnet: '10.33.30.0/24',
  pools: [
    {
      pool: '10.33.30.200 - 10.33.30.250',
    },
  ],
  'option-data': [
    {
      name: 'routers',
      data: '10.33.30.254',
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
