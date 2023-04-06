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

resource "aws_route53_record" "do53" {
  zone_id = data.aws_route53_zone.rubykaigi_net-private.zone_id
  name    = "do53.resolver.rubykaigi.net"
  type    = "CNAME"
  ttl     = 300
  records = [
    aws_lb.nlb.dns_name,
  ]
}
resource "aws_route53_record" "caa" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value
  name     = "resolver.rubykaigi.net"
  type     = "CAA"
  ttl      = 300
  records = [
    "0 issue \"amazonaws.com\"",
    "0 issue \"letsencrypt.org\"",
    "0 issue \"sectigo.com\"", # ZeroSSL
  ]
}
