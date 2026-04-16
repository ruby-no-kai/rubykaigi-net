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
      hostname: 'wire-01-venue',
      duid: '00:02:00:00:ba:2c:33:00:41',
      'ip-address': '10.33.100.21',
    },
    {
      hostname: 'wire-02-venue',
      duid: '00:02:00:00:ba:2c:33:00:42',
      'ip-address': '10.33.100.22',
    },
    {
      hostname: 'show-01-venue',
      duid: '00:02:00:00:ba:2c:33:00:75',
      'ip-address': '10.33.100.50',
    },
    {
      hostname: 'nat-61-venue',
      duid: '00:02:00:00:ba:2c:33:00:23',
      'ip-address': '10.33.100.61',
    },
    {
      hostname: 'nat-62-venue',
      duid: '00:02:00:00:ba:2c:33:00:24',
      'ip-address': '10.33.100.62',
    },
    { hostname: 'rk-srn19a1', 'ip-address': '10.33.100.80' },
    { hostname: 'rk-srn19a2', 'ip-address': '10.33.100.81' },
    { hostname: 'rk-srnp19a1', 'ip-address': '10.33.100.82' },
    { hostname: 'rk-srnp19a2', 'ip-address': '10.33.100.83' },
    { hostname: 'rk-srnp19a3', 'ip-address': '10.33.100.84' },
    { hostname: 'rk-srnp19a4', 'ip-address': '10.33.100.85' },
    { hostname: 'rk-srnp19a5', 'ip-address': '10.33.100.86' },
    { hostname: 'rk-srnp19a6', 'ip-address': '10.33.100.87' },
    { hostname: 'rk-srnp19a7', 'ip-address': '10.33.100.88' },
    { hostname: 'rk-srnp19a8', 'ip-address': '10.33.100.89' },
  ],
}
