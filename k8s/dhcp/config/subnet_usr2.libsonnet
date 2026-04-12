local parent = import './subnet_usr.libsonnet';
local parentDomainName = 'usr.venue.rubykaigi.net';
local domainName = 'usr2.venue.rubykaigi.net';
parent {
  id: 20400,
  subnet: '10.33.124.0/24',
  pools: [
    { pool: '10.33.124.100 - 10.33.124.250' },
  ],
  'option-data': std.map(
    function(o)
      if o.name == 'routers' then o { data: '10.33.124.254' }
      else if o.name == 'domain-name' then o { data: domainName }
      else if o.name == 'domain-search' then o { data: std.strReplace(o.data, parentDomainName, domainName) }
      else o,
    super['option-data'],
  ),
}
