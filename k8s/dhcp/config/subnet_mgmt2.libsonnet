local consts = import './consts.libsonnet';
local domainName = 'mgmt2.venue.rubykaigi.net';
{
  id: 21000,
  subnet: '10.33.120.0/24',
  pools: [
    {
      pool: '10.33.120.200 - 10.33.120.250',
    },
  ],
  'require-client-classes': consts.pxe_client_classes,
  'option-data': [
    {
      name: 'routers',
      data: '10.33.120.254',
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
