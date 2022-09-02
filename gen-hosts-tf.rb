require 'ipaddr'

host_lines = File.read(File.join(__dir__, 'hosts.txt'))

HostInfo = Struct.new(:dc, :network, :cidr, :ip, :name, :iface, :mac, :primary)
hosts = host_lines.lines.
  map { |l| HostInfo.new(*l.chomp.split(?\t, 7).map(&:strip), false) }.
  reject { |_| _.ip.nil? || _.ip.empty? }.
  group_by { |_| [_.dc, _.name, _.ip.include?(?:)] }.
  map { |_, ips| ips[0].primary = true; ips }


RRSet = Struct.new(:zone, :name, :type, :records)
rrsets = []
hosts.each do |host_ips|
  host_ips.each do |host|
    v6 = host.ip.include?(?:)
    ip = IPAddr.new(host.ip)
    fqdn = "#{host.name}.#{host.dc}.rubykaigi.net."
    fqdn6 = "#{host.name}.#{host.dc}.dualstack.rubykaigi.net."

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
        rrsets.push(RRSet.new(zone, fqdn6, 'AAAA', [host.ip]))
      else
        rrsets.push(RRSet.new(zone,  "#{rev}.", 'PTR', [fqdn]))
        rrsets.push(RRSet.new(zone, fqdn6, 'A', [host.ip]))
        rrsets.push(RRSet.new(zone, fqdn, 'A', [host.ip]))
      end
    end

    iface_fqdn = "#{host.iface}.#{fqdn}"
    rrsets.push(RRSet.new(zone, iface_fqdn, v6 ? 'AAAA' : 'A', [host.ip]))
    rrsets.push(RRSet.new(zone, "#{host.network}.#{fqdn}", 'CNAME', [iface_fqdn])) if host.network != 'ptp' && host.network != host.iface && !host.network.empty?
    rrsets.push(RRSet.new(zone, "#{rev}.", 'PTR', [iface_fqdn]))
  end
end

parts = []
rrsets.uniq { |rr|  [rr.type, rr.name] }.each do |rr|
  zone = case
         when rr.type == 'PTR' && rr.zone == :private
           "  zone_id = data.aws_route53_zone.ptr-10.zone_id"
         when rr.zone == :private
           "  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id"
         when rr.name.match?(/(?:\.|^)rubykaigi\.net\.$/)
           "  for_each = local.rubykaigi_net_zones\n  zone_id  = each.value\n"
         when rr.name.match?(/(?:\.|^)a\.c\.0\.0\.5\.8\.0\.f\.d\.0\.1\.0\.0\.2\.ip6\.arpa\.$/)
           "  zone_id = aws_route53_zone.ptr-ip6.zone_id"
         else
           warn "Unknown zone: #{rr.inspect}"
           next
         end
  parts.push <<~EOF
    resource "aws_route53_record" "host_#{rr.name.tr('.','_').sub(/_$/,'')}_#{rr.type}" {
    #{zone}

      name = "#{rr.name.sub(/\.$/,'')}"
      type = "#{rr.type}"
      ttl  = 60
      records = [
        "#{rr.records[0]}",
      ]
    }
  EOF
end

File.write "tf/dns-hosts/hosts.tf", parts.join(?\n)
