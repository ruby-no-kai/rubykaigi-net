#!/usr/bin/env ruby

# Generate cloudprober targets JSON from Route53.
# Run `./gen-cloudporber.rb --apply` to apply.

require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'aws-sdk-route53'
  gem 'ipaddr'
  gem 'json'
  gem 'pathname'
  gem 'resolv'
  gem 'rexml'
end

TARGETS = [
  {
    zone: 'Z05547502KT77L0O53UWK',
    network: '10.33.0.0/16',
    targets: [
      /\Alo\.[\w-]+\.(?:hnd|nrt|itm|venue)\./,
      /\Amanagement\.wlc-[\w-]+\.venue\./,
      /\Airb-1000\.cs-[\w-]+\.venue\./,
      /\Avlan1000\.[ae]s-[\w-]+\.venue\./,
    ],
    labels: {
      network: 'private',
    }
  },
  {
    zone: 'Z05547502KT77L0O53UWK',
    network: '192.50.220.0/24',
    targets: [
      # /\A[\w-]+\.\w+-kmc\./,
      /\Age-0-0-5\.br-01\./,
    ],
    labels: {
      network: 'public',
    }
  },
  {
    zone: 'Z05547502KT77L0O53UWK',
    network: '2001:0df0:8500:ca00::/56',
    targets: [
      /\Abr-01\.[\w-]+\.dualstack\./,
    ],
    labels: {
      network: 'public',
    }
  },
]

@r53 = Aws::Route53::Client.new

@zones = {}
def fetch_rrsets(zone_id)
  @zones[zone_id] ||=
    begin
      rrsets = []
      cursor = {}
      begin
        result = @r53.list_resource_record_sets({
          hosted_zone_id: zone_id,
          **cursor,
        })
        rrsets.concat(result.resource_record_sets)
        cursor = {
          start_record_name: result.next_record_name,
          start_record_type: result.next_record_type,
          start_record_identifier: result.next_record_identifier,
        }
      end while result.is_truncated
      rrsets
    end
end

@targets = {4 => [], 6 => []}

TARGETS.each do |h|
  network = IPAddr.new(h[:network])

  if h[:zone]
    rrsets = fetch_rrsets(h[:zone])

    if network.ipv4?
      rrtype = 'A'
      v4v6 = 4
    else
      rrtype = 'AAAA'
      v4v6 = 6
    end

    rrsets = rrsets.select {|rrset| rrset.type == rrtype }

    h[:targets].each do |t|
      rrsets.each do |rrset|
        name = rrset.name.sub(/.\z/, '')
        next unless t === name
        next if /recon|as-01|tun-03/ =~ name  # rk25

        if rrset.resource_records.empty?
          warn "#{name} has no static #{rrtype} records"
        else
          unless rr = rrset.resource_records.find {|rr| network.include? IPAddr.new(rr.value) }
            warn "#{name} has no addresses in #{network}"
          else
            @targets[v4v6] << {
              name: name,
              ip: rr.value,
              labels: h[:labels]
            }
          end
        end
      end
    end
  end
end

[4, 6].each do |v4v6|
  path = Pathname(__dir__) + "gen/cloudprober/targets#{v4v6}.json"
  path.parent.mkpath
  File.write(path, JSON.pretty_unparse({resource: @targets[v4v6]}))

  if ARGV.include?('--apply')
    system(*%W[aws s3 cp #{path} s3://rubykaigi-public/rknet/cloudprober/], exception: true)
  end
end

