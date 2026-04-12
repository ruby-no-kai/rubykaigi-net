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
  reservations: [],
}
