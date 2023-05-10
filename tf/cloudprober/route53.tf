data "aws_route53_zone" "rubykaigi_net-public" {
  name         = "rubykaigi.net."
  private_zone = false
}

data "aws_route53_zone" "rubykaigi_net-private" {
  name         = "rubykaigi.net."
  private_zone = true
}

resource "aws_route53_record" "cloudprober-az-c" {
  zone_id = data.aws_route53_zone.rubykaigi_net-private.zone_id
  name    = "${replace(aws_instance.cloudprober-az-c.private_ip, ".", "-")}.apne1c.cloudprober.rubykaigi.net"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.cloudprober-az-c.private_ip,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cloudprober-srv" {
  zone_id = data.aws_route53_zone.rubykaigi_net-private.zone_id
  name    = "_prometheus._http.cloudprober.rubykaigi.net"
  type    = "SRV"
  ttl     = 300
  records = [
    "0 0 ${local.cloudprober_port} ${aws_route53_record.cloudprober-az-c.fqdn}",
    "0 0 ${local.cloudprober_port} cloudprober-01.venue.rubykaigi.net"
  ]
}
