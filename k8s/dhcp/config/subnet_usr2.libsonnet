local consts = import './consts.libsonnet';
local domainName = 'usr2.venue.rubykaigi.net';
{
  id: 20400,
  subnet: '10.33.124.0/24',
  'require-client-classes': ['main_ssid'],
  pools: [
    {
      pool: '10.33.124.100 - 10.33.124.250',
    },
  ],
  'option-data': [
    {
      name: 'routers',
      data: '10.33.124.254',
    },
    {
      name: 'domain-name',
      data: domainName,
    },
    {
      name: 'domain-search',
      data: std.join(', ', consts.search_domains + [domainName, 'venue.rubykaigi.net']),
    },
    {
      name: 'domain-name-servers',
      data: std.join(', ', consts.dns_resolvers_usr),
    },
  ],
}
