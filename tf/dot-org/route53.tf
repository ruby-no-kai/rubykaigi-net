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

resource "aws_route53_record" "storage-rk-o-a" {
  for_each = local.rubykaigi_net_zones
  name     = "storage-rk-o.rubykaigi.net."
  zone_id  = each.value
  type     = "A"
  alias {
    name                   = aws_cloudfront_distribution.storage.domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront https://docs.aws.amazon.com/Route53/latest/APIReference/API_AliasTarget.html
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "storage-rk-o-aaaa" {
  for_each = local.rubykaigi_net_zones
  name     = "storage-rk-o.rubykaigi.net."
  zone_id  = each.value
  type     = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.storage.domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront https://docs.aws.amazon.com/Route53/latest/APIReference/API_AliasTarget.html
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "storage-rk-o-https" {
  for_each = local.rubykaigi_net_zones
  name     = "storage-rk-o.rubykaigi.net."
  zone_id  = each.value
  type     = "HTTPS"
  alias {
    name                   = aws_cloudfront_distribution.storage.domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront https://docs.aws.amazon.com/Route53/latest/APIReference/API_AliasTarget.html
    evaluate_target_health = true
  }
}
