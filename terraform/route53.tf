resource "aws_route53_zone" "rubykaigi-net_public" {
  name = "rubykaigi.net"
}

resource "aws_route53_zone" "rubykaigi-net_private" {
  name = "rubykaigi.net"

  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_zone_association" "rubykaigi-net_main" {
  zone_id = aws_route53_zone.rubykaigi-net_private.zone_id
  vpc_id  = aws_vpc.main.id
}

locals {
  rubykaigi_net_zones = toset([aws_route53_zone.rubykaigi-net_public.zone_id, aws_route53_zone.rubykaigi-net_private.zone_id])
}

# common
resource "aws_route53_record" "caa-rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "rubykaigi.net."
  zone_id  = each.value
  type     = "CAA"
  ttl      = 60
  records = [
    "0 issue \"amazonaws.com\"",
    "0 issue \"letsencrypt.org\"",
  ]
}
resource "aws_route53_record" "mx-rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "rubykaigi.net."
  zone_id  = each.value
  type     = "MX"
  ttl      = 60
  records = [
    "0 .", # null mx
  ]
}
resource "aws_route53_record" "txt-rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "rubykaigi.net."
  zone_id  = each.value
  type     = "TXT"
  ttl      = 60
  records = [
    "v=spf1 -all",
  ]
}
resource "aws_route53_record" "dmarc-rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "_dmarc.rubykaigi.net."
  zone_id  = each.value
  type     = "TXT"
  ttl      = 60
  records = [
    "v=DMARC1; p=reject",
  ]
}
