local parent = import './subnet_life.libsonnet';
local parentDomainName = 'life.venue.rubykaigi.net';
local domainName = 'life2.venue.rubykaigi.net';
parent {
  id: 20101,
  subnet: '10.33.121.0/24',
  pools: [
    { pool: '10.33.121.100 - 10.33.121.250' },
  ],
  'option-data': std.map(
    function(o)
      if o.name == 'routers' then o { data: '10.33.121.254' }
      else if o.name == 'domain-name' then o { data: domainName }
      else if o.name == 'domain-search' then o { data: std.strReplace(o.data, parentDomainName, domainName) }
      else o,
    super['option-data'],
  ),
  reservations: [],
}
