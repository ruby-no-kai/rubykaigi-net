data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.main.id
}

data "aws_security_group" "eks-node" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    "aws:eks:cluster-name"        = "rknet",
    "kubernetes.io/cluster/rknet" = "owned"
  }
}

resource "aws_security_group" "v6gw" {
  name   = "v6gw"
  vpc_id = data.aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "ip6tnl" {
  for_each = tomap({
    ipv6 = 41,
  })

  security_group_id = aws_security_group.v6gw.id

  ip_protocol = each.value
  cidr_ipv6   = "2001:df0:8500:ca00::/120"
  from_port   = -1
  to_port     = -1
}

resource "aws_vpc_security_group_ingress_rule" "bgp-eks-node" {
  security_group_id            = aws_security_group.v6gw.id
  referenced_security_group_id = data.aws_security_group.eks-node.id

  ip_protocol = "tcp"
  from_port   = 179
  to_port     = 179
}

resource "aws_vpc_security_group_ingress_rule" "bgp-peer-v6gw" {
  security_group_id            = aws_security_group.v6gw.id
  referenced_security_group_id = aws_security_group.v6gw.id

  ip_protocol = "tcp"
  from_port   = 179
  to_port     = 179
}

resource "aws_vpc_security_group_ingress_rule" "vxlan-eks-node" {
  security_group_id            = aws_security_group.v6gw.id
  referenced_security_group_id = data.aws_security_group.eks-node.id

  ip_protocol = "udp"
  from_port   = 4789
  to_port     = 4789
}

resource "aws_vpc_security_group_ingress_rule" "vxlan-peer-v6gw" {
  security_group_id            = aws_security_group.v6gw.id
  referenced_security_group_id = aws_security_group.v6gw.id

  ip_protocol = "udp"
  from_port   = 4789
  to_port     = 4789
}
