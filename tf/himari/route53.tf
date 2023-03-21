resource "aws_route53_record" "idp_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "idp.rubykaigi.net."
  zone_id  = each.value
  type     = "CNAME"
  ttl      = 60
  records  = [aws_cloudfront_distribution.idp-rubykaigi-net.domain_name]
}

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
