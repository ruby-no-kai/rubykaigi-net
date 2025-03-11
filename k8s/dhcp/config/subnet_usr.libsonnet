local consts = import './consts.libsonnet';
local domainName = 'usr.venue.rubykaigi.net';
{
  id: 400,
  subnet: '10.33.64.0/20',
  pools: [
    {
      pool: '10.33.65.0 - 10.33.71.255',
      'option-data': [
        {
          name: 'domain-name-servers',
          data: std.join(', ', consts.dns_resolvers_usr),
        },
      ],
    },
    {
      pool: '10.33.72.0 - 10.33.79.250',
      'option-data': [
        {
          name: 'domain-name-servers',
          data: std.join(', ', std.reverse(consts.dns_resolvers_usr)),
        },
      ],
    },
  ],
  'option-data': [
    {
      name: 'routers',
      data: '10.33.79.254',
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
      name: 'v6-only-preferred',
      data: '1800',
    },
  ],
}
