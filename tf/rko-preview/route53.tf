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

resource "aws_route53_record" "rko-preview_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "rko-preview.rubykaigi.net."
  zone_id  = each.value
  type     = "CNAME"
  ttl      = 60
  records  = [aws_cloudfront_distribution.rko-preview.domain_name]

}
resource "aws_route53_record" "wild_rko-preview_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "*.rko-preview.rubykaigi.net."
  zone_id  = each.value
  type     = "CNAME"
  ttl      = 60
  records  = [aws_cloudfront_distribution.rko-preview.domain_name]
}
