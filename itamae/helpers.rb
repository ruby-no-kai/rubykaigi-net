module TemplateHelpers
  # Embed IPv4 address or CIDR in Pref64::/n
  def embed_v4(pref64n, v4)
    v4addr, v4prefixlen = v4.split(?/, 2)
    v6prefixlen = v4prefixlen.to_i + 96 if v4prefixlen

    pref64n.sub('::/96', [sprintf(':%02x%02x:%02x%02x', *v4addr.split(?.).map(&:to_i)), *v6prefixlen].join(?/)) or fail 'pref64n is not /96'
  end

  # Parse the IPv6 string representation into an array of hextets.
  def parse_v6addr(str)
    head, tail = str.split('::', 2)
    hextets = head.split(?:).map {|h| h.to_i(16) }
    if tail
      tail = tail.split(?:).map {|h| h.to_i(16) }
      hextets << Array.new(8 - hextets.count - tail.count, 0) << tail
    end
    fail 'invalid IPv6 addr' if hextets.size != 8
    hextets
  end

  # Format the array of hextets into IPv6 string representation.
  def format_v6addr(addr)
    addr.map {|h| h.to_s(16) }.join(?:)
  end

  # Convert IPv6 CIDR to min-max range
  def v6range(v6cidr)
    v6addr, v6prefixlen = v6cidr.split(?/, 2)
    v6prefixlen = v6prefixlen&.to_i
    return "[#{v6addr}]" if !v6prefixlen || v6prefixlen == 128
    v6addr = parse_v6addr(v6addr)

    hostmask = 8.times.map do |i|
      n = (i+1) * 16 - v6prefixlen
      n > 0 ? (1 << n) - 1 : 0
    end

    min = v6addr.zip(hostmask).map {|a, b| a & ~b }
    max = v6addr.zip(hostmask).map {|a, b| a | b }
    "[#{format_v6addr(min)}]-[#{format_v6addr(max)}]"
  end
end

MItamae::ResourceExecutor::Template::RenderContext.include(TemplateHelpers)
