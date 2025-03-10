resource "aws_security_group_rule" "k8s-node_tftp" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  type              = "ingress"
  description       = "tftp tftp"
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
  description       = "tftp tftp-healtz"
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks = [
    "10.33.128.0/18", # aws
  ]
}
resource "aws_security_group_rule" "k8s-node_envoy-healthz" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  type              = "ingress"
  description       = "tftp envoy-healthz"
  from_port         = 9901
  to_port           = 9901
  protocol          = "tcp"
  cidr_blocks = [
    "10.33.128.0/18", # aws
  ]
}
resource "aws_security_group_rule" "k8s-node_http" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "tftp envoy-http"
  type              = "ingress"
  from_port         = 11080
  to_port           = 11080
  protocol          = "tcp"
  cidr_blocks = [
    "10.33.128.0/18", # aws
  ]
}
