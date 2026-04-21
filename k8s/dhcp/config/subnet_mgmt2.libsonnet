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
  reservations:
    [
      {
        hostname: 'cloudprober-01-venue',
        duid: '00:02:00:00:ba:2c:33:09:c1',
        'ip-address': '10.33.120.190',
      },
      {
        hostname: 'cloudprober-02-venue',
        duid: '00:02:00:00:ba:2c:33:09:c2',
        'ip-address': '10.33.120.191',
      },

    ] + (import './reservations_asset_tag.libsonnet')('10.33.120'),
}
