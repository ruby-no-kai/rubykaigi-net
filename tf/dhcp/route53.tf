data "aws_route53_zone" "rubykaigi-net_public" {
  name         = "rubykaigi.net."
  private_zone = false
}

data "aws_route53_zone" "rubykaigi-net_private" {
  name         = "rubykaigi.net."
  private_zone = true
}

locals {
  rubykaigi_net_zones = toset([data.aws_route53_zone.rubykaigi-net_public.zone_id, data.aws_route53_zone.rubykaigi-net_private.zone_id])
}

// TODO: tmp air.venue.rk.n
resource "aws_route53_record" "cisco-capwap-controller" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value
  name     = "CISCO-CAPWAP-CONTROLLER.air.venue.rubykaigi.net."
  type     = "A"
  ttl      = 60
  records = [
    "10.33.2.2",
  ]
}
