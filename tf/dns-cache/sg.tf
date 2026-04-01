resource "aws_security_group" "nlb" {
  name        = "dns-cache-nlb"
  description = "dns-cache NLB"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "dns"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.33.0.0/16"]
  }

  ingress {
    description = "dns-udp"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.33.0.0/16"]
  }

  ingress {
    description = "dns-tls"
    from_port   = 853
    to_port     = 853
    protocol    = "tcp"
    cidr_blocks = ["10.33.0.0/16"]
  }

  ingress {
    description = "dns-quic"
    from_port   = 853
    to_port     = 853
    protocol    = "udp"
    cidr_blocks = ["10.33.0.0/16"]
  }

  ingress {
    description = "dns-https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.33.0.0/16"]
  }

  ingress {
    description = "dns-https-udp"
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["10.33.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }
}

resource "aws_security_group_rule" "k8s-node_dns-cache" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "dns-cache-dns"
  type                     = "ingress"
  from_port                = local.dns_cache_dns_target_port
  to_port                  = local.dns_cache_dns_target_port
  protocol                 = "udp"
  source_security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "k8s-node_dns-cache-tcp" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "dns-cache-dns-tcp"
  type                     = "ingress"
  from_port                = local.dns_cache_dns_target_port
  to_port                  = local.dns_cache_dns_target_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "k8s-node_dns-cache-tls" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "dns-cache-dns-tcp"
  type                     = "ingress"
  from_port                = local.dns_cache_dns_tls_target_port
  to_port                  = local.dns_cache_dns_tls_target_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "k8s-node_dns-cache-quic" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "dns-cache-dns-tcp"
  type                     = "ingress"
  from_port                = local.dns_cache_dns_tls_target_port
  to_port                  = local.dns_cache_dns_tls_target_port
  protocol                 = "udp"
  source_security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "k8s-node_dns-cache-https" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "dns-cache-dns-https"
  type                     = "ingress"
  from_port                = local.dns_cache_dns_https_target_port
  to_port                  = local.dns_cache_dns_https_target_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "k8s-node_dns-cache-https-udp" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "dns-cache-dns-https-udp"
  type                     = "ingress"
  from_port                = local.dns_cache_dns_https_target_port
  to_port                  = local.dns_cache_dns_https_target_port
  protocol                 = "udp"
  source_security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "k8s-node_unbound_healthz" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "dns-cache-unbound-healthz"
  type                     = "ingress"
  from_port                = local.dns_cache_unbound_healthz_target_port
  to_port                  = local.dns_cache_unbound_healthz_target_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "k8s-node_envoy_healthz" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "dns-cache-envoy-healthz"
  type                     = "ingress"
  from_port                = local.dns_cache_envoy_healthz_target_port
  to_port                  = local.dns_cache_envoy_healthz_target_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nlb.id
}
