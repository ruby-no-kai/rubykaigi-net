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

resource "aws_route53_record" "tftp" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value
  name     = "tftp.rubykaigi.net"
  type     = "CNAME"
  ttl      = 60
  records = [
    aws_lb.nlb.dns_name,
  ]
}

