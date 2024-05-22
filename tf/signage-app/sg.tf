resource "aws_security_group" "captioner" {
  vpc_id      = data.aws_vpc.main.id
  name        = "signage-captioner"
  description = "signage-app/caption"
}

resource "aws_security_group_rule" "captioner_udpmedialive" {
  security_group_id = aws_security_group.captioner.id
  type              = "ingress"
  from_port         = 10000
  to_port           = 40000
  protocol          = "udp"
  #cidr_blocks       = toset([for x in data.aws_vpc.main.cidr_block_associations : x.cidr_block])
  source_security_group_id = aws_security_group.medialive.id
}

resource "aws_security_group" "medialive" {
  vpc_id      = data.aws_vpc.main.id
  name        = "signage-medialive"
  description = "signage-medialive"
}

resource "aws_security_group_rule" "medialive_egress" {
  security_group_id = aws_security_group.medialive.id
  type              = "egress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]

}
resource "aws_security_group_rule" "medialive_ingress" {
  security_group_id = aws_security_group.medialive.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1
  to_port           = 65535
  cidr_blocks = [
    "10.33.128.0/17",
    "10.33.0.0/24",
    "10.33.1.0/24",
    "10.33.21.0/24",
    "10.33.100.0/24",
  ]
}

resource "aws_medialive_input_security_group" "anywhere" {
  whitelist_rules {
    cidr = "0.0.0.0/0"
  }
}
