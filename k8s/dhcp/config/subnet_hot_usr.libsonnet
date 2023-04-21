local consts = import './consts.libsonnet';
local domainName = 'test.hot.rubykaigi.net';
{
  id: 933,
  subnet: '10.33.33.0/24',
  pools: [
    {
      pool: '10.33.33.100 - 10.33.33.250',
    },
  ],
  'option-data': [
    {
      name: 'routers',
      data: '10.33.33.254',
    },
    {
      name: 'domain-name-servers',
      data: std.join(', ', consts.dns_resolvers_usr),
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
