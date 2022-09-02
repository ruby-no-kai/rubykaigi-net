
data "aws_route53_zone" "rubykaigi-net_public" {
  name         = "rubykaigi.net."
  private_zone = false
}

data "aws_route53_zone" "rubykaigi-net_private" {
  name         = "rubykaigi.net."
  private_zone = true
}

data "aws_route53_zone" "ptr-10" {
  name         = "10.in-addr.arpa."
  private_zone = true
}

resource "aws_route53_zone" "ptr-ip6" {
  name = "a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa."
}

locals {
  rubykaigi_net_zones = toset([data.aws_route53_zone.rubykaigi-net_public.zone_id, data.aws_route53_zone.rubykaigi-net_private.zone_id])
}
