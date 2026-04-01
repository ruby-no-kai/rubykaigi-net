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

resource "aws_route53_record" "acme-responder" {
  zone_id = data.aws_route53_zone.rubykaigi_net-private.zone_id
  name    = "acme-responder.rubykaigi.net"
  type    = "A"
  ttl     = 60
  records = [
    aws_instance.acme-responder.private_ip,
  ]
}
