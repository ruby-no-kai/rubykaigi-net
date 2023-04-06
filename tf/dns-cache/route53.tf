data "aws_route53_zone" "rubykaigi_net-private" {
  name         = "rubykaigi.net."
  private_zone = true
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
