data "aws_security_group" "elb_http" {
  name = "elb-http"
}
data "aws_security_group" "bastion" {
  name = "bastion"
}
resource "aws_security_group_rule" "common-lb-to-node" {
  security_group_id        = module.cluster.config.node_security_group
  type                     = "ingress"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.elb_http.id
}

resource "aws_security_group_rule" "bastion-to-node" {
  security_group_id        = module.cluster.config.node_security_group
  type                     = "ingress"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.bastion.id
}
