local consts = import './consts.libsonnet';
local domainName = 'life.venue.rubykaigi.net';
{
  id: 101,
  subnet: '10.33.1.0/24',
  pools: [
    {
      pool: '10.33.1.100 - 10.33.1.250',
    },
  ],
  'option-data': [
    {
      name: 'routers',
      data: '10.33.1.254',
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
  reservations: [
    { 'hw-address': '58:38:79:67:d1:29', hostname: 'printer', 'ip-address': '10.33.1.10' },
  ],
}
