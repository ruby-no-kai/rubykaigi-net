#!/usr/bin/env ruby
require 'json'
require 'ipaddr'

host_lines = File.read(File.join(__dir__, 'hosts.txt'))


def escape_name(str)
  str.gsub(/[^a-zA-Z0-9]/,'-')
end

HostInfo = Struct.new(:dc, :network, :cidr, :ip, :name, :iface, :mac, :primary) do
  def safe_name
    @safe_name ||= escape_name(name)
  end

  def safe_iface
    @safe_iface ||= escape_name(iface)
  end
end
hosts = host_lines.lines(chomp: true).grep_v(/\A\s*\Z/).
  map { |l| HostInfo.new(*l.split(?\t, 7).map(&:strip), false) }.
  reject { |_| _.ip.nil? || _.ip.empty? }.
  group_by { |_| [_.dc, _.name, _.ip.include?(?:)] }.
  map { |_, ips| ips[0].primary = true; ips }



RRSet = Struct.new(:zone, :name, :type, :records, :primary)
rrsets = []
hosts.each do |host_ips|
  host_ips.each do |host|
    v6 = host.ip.include?(?:)
    ip = IPAddr.new(host.ip)

    next if host.safe_name.empty?

    fqdn = "#{host.safe_name}.#{host.dc}.rubykaigi.net."
    fqdn6 = "#{host.safe_name}.#{host.dc}.dualstack.rubykaigi.net."

    zone = case
    when IPAddr.new('10.0.0.0/8').include?(ip)
      :private
    else
      :public
    end

    rev = ip.reverse.gsub(/\.220\.50\.192\.in-addr\.arpa$/, '.220.50.192.reverse.rubykaigi.net')

    if host.primary
      # v6 may not be able for management, so...
      if v6
        rrsets.push(RRSet.new(zone, fqdn6, 'AAAA', [host.ip], true))
      else
        rrsets.push(RRSet.new(zone,  "#{rev}.", 'PTR', [fqdn]))
        rrsets.push(RRSet.new(zone, fqdn6, 'A', [host.ip]))
        rrsets.push(RRSet.new(zone, fqdn, 'A', [host.ip], true))
      end
    end

    iface_fqdn = host.safe_iface.empty? ? nil : "#{host.safe_iface}.#{fqdn}"
    if iface_fqdn
      rrsets.push(RRSet.new(zone, iface_fqdn, v6 ? 'AAAA' : 'A', [host.ip]))
      rrsets.push(RRSet.new(zone, "#{host.network}.#{fqdn}", 'CNAME', [iface_fqdn])) if host.network != 'ptp' && host.network != host.iface && !host.network.empty?
      rrsets.push(RRSet.new(zone, "#{rev}.", 'PTR', [iface_fqdn]))
    end
  end
end

parts = []
rrsets.uniq { |rr|  [rr.type, rr.name] }.each do |rr|
  zone = case
         when rr.type == 'PTR' && rr.zone == :private
           'ptr-10'
         when rr.zone == :private
           'rubykaigi.net-private'
         when rr.name.match?(/(?:\.|^)rubykaigi\.net\.$/)
           'rubykaigi.net-common'
         when rr.name.match?(/(?:\.|^)a\.c\.0\.0\.5\.8\.0\.f\.d\.0\.1\.0\.0\.2\.ip6\.arpa\.$/)
           'ptr-ip6'
         else
           warn "Unknown zone: #{rr.inspect}"
           next
         end
  parts.push(
    zone: zone,
    name: rr.name,
    type: rr.type,
    records: rr.records,
  )
end


deadman = rrsets.select(&:primary).uniq { |rr|  [rr.type, rr.name] }.map do |rr|
  "#{rr.name} #{rr.records[0]}"
end

#File.write "tf/dns-hosts/hosts.tf", parts.join(?\n)
File.write "route53/hosts.json", "#{JSON.pretty_generate(records: parts)}\n"
File.write "deadman.conf", deadman.join(?\n)
