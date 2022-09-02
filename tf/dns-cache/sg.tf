resource "aws_security_group_rule" "k8s-node_dns-cache" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "dns-cache-dns"
  type              = "ingress"
  from_port         = local.dns_cache_dns_target_port
  to_port           = local.dns_cache_dns_target_port
  protocol          = "udp"
  cidr_blocks       = ["10.33.0.0/16"]
}

resource "aws_security_group_rule" "k8s-node_dns-cache-tcp" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "dns-cache-dns-tcp"
  type              = "ingress"
  from_port         = local.dns_cache_dns_target_port
  to_port           = local.dns_cache_dns_target_port
  protocol          = "tcp"
  cidr_blocks       = ["10.33.0.0/16"]
}

resource "aws_security_group_rule" "k8s-node_healthz" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "dns-cache-healthz"
  type              = "ingress"
  from_port         = local.dns_cache_healthz_target_port
  to_port           = local.dns_cache_healthz_target_port
  protocol          = "tcp"
  cidr_blocks       = ["10.33.0.0/16"] # XXX: NLB node
}
