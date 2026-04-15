data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.main.id
}

resource "aws_security_group" "wire" {
  name   = "wire"
  vpc_id = data.aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "wg6" {
  security_group_id = aws_security_group.wire.id

  ip_protocol = "udp"
  cidr_ipv6   = "::/0"
  from_port   = 8700
  to_port     = 8799
}

resource "aws_vpc_security_group_ingress_rule" "wg4" {
  security_group_id = aws_security_group.wire.id

  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8700
  to_port     = 8799
}
