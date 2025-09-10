resource "aws_route53_zone" "rubykaigi-net_public" {
  name = "rubykaigi.net"
  tags = {
    Component = "core/dns"
  }
}

resource "aws_route53_zone" "rubykaigi-net_private" {
  name = "rubykaigi.net"

  lifecycle {
    ignore_changes = [vpc]
  }

  tags = {
    Component = "core/dns"
  }
}

resource "aws_route53_zone_association" "rubykaigi-net_main" {
  zone_id = aws_route53_zone.rubykaigi-net_private.zone_id
  vpc_id  = aws_vpc.main.id
}

resource "aws_route53_zone" "ptr-10" {
  name = "10.in-addr.arpa"

  lifecycle {
    ignore_changes = [vpc]
  }

  tags = {
    Component = "core/dns"
  }
}

resource "aws_route53_zone_association" "ptr-10_main" {
  zone_id = aws_route53_zone.ptr-10.zone_id
  vpc_id  = aws_vpc.main.id
}

locals {
  rubykaigi_net_zones = toset([aws_route53_zone.rubykaigi-net_public.zone_id, aws_route53_zone.rubykaigi-net_private.zone_id])
}

# see also //route53/rubykaigi.net.route
