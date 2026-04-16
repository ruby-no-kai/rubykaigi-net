local parent = import './subnet_mgmt.libsonnet';
local parentDomainName = 'mgmt.venue.rubykaigi.net';
local domainName = 'mgmt2.venue.rubykaigi.net';
parent {
  id: 21000,
  subnet: '10.33.120.0/24',
  pools: [
    { pool: '10.33.120.200 - 10.33.120.250' },
  ],
  'option-data': std.map(
    function(o)
      if o.name == 'routers' then o { data: '10.33.120.254' }
      else if o.name == 'domain-name' then o { data: domainName }
      else if o.name == 'domain-search' then o { data: std.strReplace(o.data, parentDomainName, domainName) }
      else o,
    super['option-data'],
  ),
  reservations: [
    { hostname: 'rk-srn19a1', 'ip-address': '10.33.120.80' },
    { hostname: 'rk-srn19a2', 'ip-address': '10.33.120.81' },
    { hostname: 'rk-srnp19a1', 'ip-address': '10.33.120.82' },
    { hostname: 'rk-srnp19a2', 'ip-address': '10.33.120.83' },
    { hostname: 'rk-srnp19a3', 'ip-address': '10.33.120.84' },
    { hostname: 'rk-srnp19a4', 'ip-address': '10.33.120.85' },
    { hostname: 'rk-srnp19a5', 'ip-address': '10.33.120.86' },
    { hostname: 'rk-srnp19a6', 'ip-address': '10.33.120.87' },
    { hostname: 'rk-srnp19a7', 'ip-address': '10.33.120.88' },
    { hostname: 'rk-srnp19a8', 'ip-address': '10.33.120.89' },
  ],
}
