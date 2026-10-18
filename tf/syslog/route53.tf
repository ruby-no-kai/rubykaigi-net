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

import {
  for_each = local.rubykaigi_net_zones
  id       = "${each.value}_syslog.rubykaigi.net_A"
  to       = aws_route53_record.syslog[each.value]
}

resource "aws_route53_record" "syslog" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value
  name     = "syslog.rubykaigi.net"
  type     = "A"
  ttl      = 60
  records  = local.nlb_ips
}
