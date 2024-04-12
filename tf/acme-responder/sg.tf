data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.main.id
}

resource "aws_security_group" "acme-responder" {
  name   = "acme-responder"
  vpc_id = data.aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "ip6tnl" {
  for_each = tomap({
    ip   = 4,
    ipv6 = 41,
  })

  security_group_id = aws_security_group.acme-responder.id

  ip_protocol = each.value
  cidr_ipv6   = "::/0"
  from_port   = -1
  to_port     = -1
}
