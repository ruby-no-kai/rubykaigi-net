resource "aws_security_group_rule" "k8s-node_dns-cache" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "dns-cache-dns"
  type              = "ingress"
  from_port         = 10053
  to_port           = 10053
  protocol          = "udp"
  cidr_blocks       = ["10.33.0.0/16"]
}

resource "aws_security_group_rule" "k8s-node_healthz" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "dns-cache-healthz"
  type              = "ingress"
  from_port         = 9176
  to_port           = 9176
  protocol          = "tcp"
  cidr_blocks       = ["10.33.0.0/16"] # XXX: NLB node
}
