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

resource "aws_route53_record" "apne1c" {
  for_each = local.rubykaigi_net_zones

  zone_id = each.value
  name    = "apne1c.acme-responder.rubykaigi.net"
  type    = "AAAA"
  ttl     = 60
  records = aws_instance.acme-responder-apne1c.ipv6_addresses
}

resource "aws_route53_record" "apne1d" {
  for_each = local.rubykaigi_net_zones

  zone_id = each.value
  name    = "apne1d.acme-responder.rubykaigi.net"
  type    = "AAAA"
  ttl     = 60
  records = aws_instance.acme-responder-apne1d.ipv6_addresses
}
