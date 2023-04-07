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

resource "aws_security_group_rule" "k8s-node_dns-cache-tls" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "dns-cache-dns-tcp"
  type              = "ingress"
  from_port         = local.dns_cache_dns_tls_target_port
  to_port           = local.dns_cache_dns_tls_target_port
  protocol          = "tcp"
  cidr_blocks       = ["10.33.0.0/16"]
}

resource "aws_security_group_rule" "k8s-node_dns-cache-https" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "dns-cache-dns-https"
  type              = "ingress"
  from_port         = local.dns_cache_dns_https_target_port
  to_port           = local.dns_cache_dns_https_target_port
  protocol          = "tcp"
  cidr_blocks       = ["10.33.0.0/16"]
}

resource "aws_security_group_rule" "k8s-node_dns-cache-https-udp" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "dns-cache-dns-https-udp"
  type              = "ingress"
  from_port         = local.dns_cache_dns_https_target_port
  to_port           = local.dns_cache_dns_https_target_port
  protocol          = "udp"
  cidr_blocks       = ["10.33.0.0/16"]
}

resource "aws_security_group_rule" "k8s-node_unbound_healthz" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "dns-cache-unbound-healthz"
  type              = "ingress"
  from_port         = local.dns_cache_unbound_healthz_target_port
  to_port           = local.dns_cache_unbound_healthz_target_port
  protocol          = "tcp"
  cidr_blocks       = [for _, s in local.nlb_subnets : s.cidr_block]
}

resource "aws_security_group_rule" "k8s-node_envoy_healthz" {
  security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
  description       = "dns-cache-envoy-healthz"
  type              = "ingress"
  from_port         = local.dns_cache_envoy_healthz_target_port
  to_port           = local.dns_cache_envoy_healthz_target_port
  protocol          = "tcp"
  cidr_blocks       = [for _, s in local.nlb_subnets : s.cidr_block]
}
