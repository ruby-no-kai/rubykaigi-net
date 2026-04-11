local consts = import './consts.libsonnet';
local domainName = 'life2.venue.rubykaigi.net';
{
  id: 20101,
  subnet: '10.33.121.0/24',
  pools: [
    {
      pool: '10.33.121.100 - 10.33.121.250',
    },
  ],
  'option-data': [
    {
      name: 'routers',
      data: '10.33.121.254',
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
