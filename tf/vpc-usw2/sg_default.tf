resource "aws_security_group" "default" {
  vpc_id      = aws_vpc.main.id
  name        = "default"
  description = "default VPC security group"
}

resource "aws_security_group_rule" "default_egress" {
  security_group_id = aws_security_group.default.id
  type              = "egress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}
