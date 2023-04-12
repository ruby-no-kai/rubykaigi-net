data "aws_security_group" "ops-lb" {
  name   = "ops-lb"
  vpc_id = data.aws_vpc.main.id
}
data "aws_security_group" "bastion" {
  name   = "bastion"
  vpc_id = data.aws_vpc.main.id
}
resource "aws_security_group_rule" "ops-lb-to-node" {
  security_group_id        = module.cluster.config.node_security_group
  type                     = "ingress"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.ops-lb.id
}
resource "aws_security_group_rule" "bastion-to-node" {
  security_group_id        = module.cluster.config.node_security_group
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = data.aws_security_group.bastion.id
}
