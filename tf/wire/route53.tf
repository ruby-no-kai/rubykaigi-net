data "aws_route53_zone" "rubykaigi_net-public" {
  name         = "rubykaigi.net."
  private_zone = false
}
data "aws_route53_zone" "rubykaigi_net-private" {
  name         = "rubykaigi.net."
  private_zone = true
}
locals {
  rubykaigi_net_zones = toset([data.aws_route53_zone.rubykaigi_net-public.zone_id, data.aws_route53_zone.rubykaigi_net-private.zone_id])
}

resource "aws_route53_record" "wire" {
  for_each = local.rubykaigi_net_zones

  zone_id = each.value
  name    = "wire.rubykaigi.net"
  type    = "AAAA"
  ttl     = 60
  records = aws_instance.wire.ipv6_addresses
}

resource "aws_route53_record" "wire_a" {
  for_each = local.rubykaigi_net_zones

  zone_id = each.value
  name    = "wire.rubykaigi.net"
  type    = "A"
  ttl     = 60
  records = [aws_instance.wire.private_ip]
}

resource "aws_route53_record" "wire_ep_a" {
  for_each = local.rubykaigi_net_zones

  zone_id = each.value
  name    = "ep.wire.rubykaigi.net"
  type    = "A"
  ttl     = 60
  records = [aws_eip.wire_overlay.public_ip]
}

resource "aws_route53_record" "wire_ep_aaaa" {
  for_each = local.rubykaigi_net_zones

  zone_id = each.value
  name    = "ep.wire.rubykaigi.net"
  type    = "AAAA"
  ttl     = 60
  records = aws_network_interface.wire_overlay.ipv6_addresses
}
