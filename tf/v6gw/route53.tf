data "aws_route53_zone" "rubykaigi_net-private" {
  name         = "rubykaigi.net."
  private_zone = true
}

resource "aws_route53_record" "origin" {
  zone_id = data.aws_route53_zone.rubykaigi_net-private.zone_id
  name    = "_bgp._tcp.v6gw.apne1.rubykaigi.net"
  type    = "SRV"
  ttl     = 30
  records = [for i in aws_instance.v6gw : "0 1 179 ${i.private_dns}."]
}
