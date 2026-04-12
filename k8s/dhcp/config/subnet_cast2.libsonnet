local parent = import './subnet_cast.libsonnet';
local parentDomainName = 'cast.venue.rubykaigi.net';
local domainName = 'cast2.venue.rubykaigi.net';
parent {
  id: 20410,
  subnet: '10.33.123.0/24',
  pools: [
    { pool: '10.33.123.100 - 10.33.123.250' },
  ],
  'option-data': std.map(
    function(o)
      if o.name == 'routers' then o { data: '10.33.123.254' }
      else if o.name == 'domain-name' then o { data: domainName }
      else if o.name == 'domain-search' then o { data: std.strReplace(o.data, parentDomainName, domainName) }
      else o,
    super['option-data'],
  ),
}
