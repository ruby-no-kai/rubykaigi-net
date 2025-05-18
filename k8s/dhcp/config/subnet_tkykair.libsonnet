local consts = import './consts.libsonnet';
local domainName = 'air.tkyk.rubykaigi.net';
{
  id: 932,
  subnet: '10.33.32.0/24',
  pools: [
    {
      pool: '10.33.32.128 - 10.33.32.160',
      'option-data': [
        {
          name: 'domain-name-servers',
          data: std.join(', ', consts.dns_resolvers_usr),
        },
      ],
    },
  ],
  'option-data': [
    {
      name: 'routers',
      data: '10.33.32.254',
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
