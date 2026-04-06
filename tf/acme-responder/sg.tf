data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.main.id
}

resource "aws_security_group" "acme-responder" {
  name   = "acme-responder"
  vpc_id = data.aws_vpc.main.id
}

locals {
  ip6tnl-remotes = toset([
    "2409:10:ba20:2f0::eb96/128",  # rola
    "2409:10:f00:400:5::eb96/128", # mahiru
  ])
}

resource "aws_vpc_security_group_ingress_rule" "ip6tnl-ip" {
  for_each = local.ip6tnl-remotes

  security_group_id = aws_security_group.acme-responder.id

  ip_protocol = 4
  cidr_ipv6   = each.value
  from_port   = -1
  to_port     = -1
}

resource "aws_vpc_security_group_ingress_rule" "ip6tnl-ip6" {
  for_each = local.ip6tnl-remotes

  security_group_id = aws_security_group.acme-responder.id

  ip_protocol = 41
  cidr_ipv6   = each.value
  from_port   = -1
  to_port     = -1
}
