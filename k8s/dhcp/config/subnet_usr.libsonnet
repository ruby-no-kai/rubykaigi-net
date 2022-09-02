local consts = import './consts.libsonnet';
local domainName = 'usr.venue.rubykaigi.net';
{
  id: 400,
  subnet: '10.33.64.0/20',
  pools: [
    {
      pool: '10.33.65.0 - 10.33.79.250',
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
      data: std.join(', ', [domainName, 'venue.rubykaigi.net'] + consts.search_domains),
    },
  ],
}
