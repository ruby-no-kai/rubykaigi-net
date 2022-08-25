resource "aws_security_group_rule" "k8s-node_dhcp" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  type              = "ingress"
  from_port         = 67
  to_port           = 67
  protocol          = "udp"
  cidr_blocks       = ["10.33.0.0/16"]
}
