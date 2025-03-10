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
  'require-client-classes': consts.pxe_client_classes,
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
      data: std.join(', ', ['f.rubykaigi.net', domainName, 'venue.rubykaigi.net'] + consts.search_domains),
    },
  ],

  reservations: [
    {
      hostname: 'nat-61-venue',
      duid: '00:02:00:00:ba:2c:33:00:23',
      'ip-address': '10.33.100.61',
    },
    {
      hostname: 'nat-61-venue',
      duid: '00:02:00:00:ba:2c:33:00:24',
      'ip-address': '10.33.100.62',
    },
  ],
}
