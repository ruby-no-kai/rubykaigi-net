resource "aws_security_group_rule" "k8s-node_radiusd" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "radius-radiusd"
  type              = "ingress"
  from_port         = 1812
  to_port           = 1812
  protocol          = "udp"
  cidr_blocks       = ["10.33.0.0/16"]
}
resource "aws_security_group_rule" "k8s-node_radiusd-tcp" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "radius-radiusd"
  type              = "ingress"
  from_port         = 1812
  to_port           = 1812
  protocol          = "tcp"
  cidr_blocks       = ["10.33.0.0/16"]
}

resource "aws_security_group_rule" "k8s-node_radius-prom" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "radius-prom-healthz"
  type              = "ingress"
  from_port         = 9812
  to_port           = 9812
  protocol          = "tcp"
  cidr_blocks       = [for _, s in local.nlb_subnets : s.cidr_block]
}
