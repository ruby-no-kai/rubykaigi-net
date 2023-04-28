local consts = import './consts.libsonnet';
local domainName = 'test.tkyk.rubykaigi.net';
{
  id: 931,
  subnet: '10.33.31.0/24',
  pools: [
    {
      pool: '10.33.31.96 - 10.33.31.127',
      'option-data': [
        {
          name: 'domain-name-servers',
          data: std.join(', ', consts.dns_resolvers_usr),
        },
      ],
    },
    {
      pool: '10.33.31.128 - 10.33.31.160',
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
