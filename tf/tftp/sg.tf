resource "aws_security_group_rule" "k8s-node_tftp" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  type              = "ingress"
  from_port         = 69
  to_port           = 69
  protocol          = "udp"
  cidr_blocks = [
    "10.33.128.0/18", # aws
    "10.33.0.0/24",   # loopback
    "10.33.1.0/24",   # life
    "10.33.2.0/24",   # air
    "10.33.100.0/24", # mgmt
  ]
}
resource "aws_security_group_rule" "k8s-node_tftp-healthz" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "udp"
  cidr_blocks = [
    "10.33.128.0/18", # aws
  ]
}
