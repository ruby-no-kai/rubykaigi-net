local parent = import './subnet_air.libsonnet';
local parentDomainName = 'air.venue.rubykaigi.net';
local domainName = 'air.venue.rubykaigi.net';
parent {
  id: 20102,
  subnet: '10.33.122.0/24',
  pools: [
    { pool: '10.33.122.150 - 10.33.122.250' },
  ],
  'option-data': std.map(
    function(o)
      if o.name == 'routers' then o { data: '10.33.122.254' }
      else if o.name == 'domain-name' then o { data: domainName }
      else if o.name == 'domain-search' then o { data: std.strReplace(o.data, parentDomainName, domainName) }
      else o,
    super['option-data'],
  ),
}
