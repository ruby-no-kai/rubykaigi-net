local consts = import './consts.libsonnet';
local domainName = 'mgmt.venue.rubykaigi.net';
{
  id: 1000,
  subnet: '10.33.100.0/24',
  pools: [
    {
      pool: '10.33.100.200 - 10.33.100.250',
    },
  ],
  'option-data': [
    {
      name: 'routers',
      data: '10.33.100.254',
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
