resource "aws_lb" "nlb" {
  name               = "dns-cache-${substr(uuid(), 0, 10)}"
  internal           = true
  load_balancer_type = "network"

  dynamic "subnet_mapping" {
    for_each = tomap(local.nlb_subnets)
    content {
      subnet_id            = subnet_mapping.value.id
      private_ipv4_address = cidrhost(subnet_mapping.value.cidr_block, 53)
    }
  }

  lifecycle {
    ignore_changes = [name]
  }
}

###

resource "aws_lb_listener" "dns" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "53"
  protocol          = "TCP_UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dns.arn
  }
}

resource "aws_lb_target_group" "dns" {
  name        = "dns-cache-dns-${substr(uuid(), 0, 10)}"
  target_type = "ip"
  port        = local.dns_cache_dns_target_port
  protocol    = "TCP_UDP"
  vpc_id      = data.aws_vpc.main.id

  connection_termination = true
  deregistration_delay   = 10

  health_check {
    protocol = "HTTP"
    port     = local.dns_cache_unbound_healthz_target_port
    path     = "/healthz"
    interval = 10
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "kubernetes_manifest" "targetgroupbinding-dns-cache-dns" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "dns-cache"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "unbound"
        "port" = "dns"
      },
      "targetGroupARN" = aws_lb_target_group.dns.arn
    }
  }
}

###

# dot & doq
resource "aws_lb_listener" "dns-tls" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "853"
  protocol          = "TCP_UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dns-tls.arn
  }
}

resource "aws_lb_target_group" "dns-tls" {
  name        = "dns-cache-dns-${substr(uuid(), 0, 10)}"
  target_type = "ip"
  port        = local.dns_cache_dns_tls_target_port
  protocol    = "TCP_UDP"
  vpc_id      = data.aws_vpc.main.id

  connection_termination = true
  deregistration_delay   = 10

  health_check {
    protocol = "HTTP"
    port     = local.dns_cache_unbound_healthz_target_port
    path     = "/healthz"
    interval = 10
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "kubernetes_manifest" "targetgroupbinding-dns-cache-dns-tls" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "dns-cache-tls"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "unbound"
        "port" = "dns-tls"
      },
      "targetGroupARN" = aws_lb_target_group.dns-tls.arn
    }
  }
}

###

resource "aws_lb_listener" "dns-https" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "TCP_UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dns-https.arn
  }
}

resource "aws_lb_target_group" "dns-https" {
  name        = "dns-cache-dns-${substr(uuid(), 0, 10)}"
  target_type = "ip"
  port        = local.dns_cache_dns_https_target_port
  protocol    = "TCP_UDP"
  vpc_id      = data.aws_vpc.main.id

  connection_termination = true
  deregistration_delay   = 10

  health_check {
    protocol = "HTTP"
    port     = local.dns_cache_envoy_healthz_target_port
    path     = "/ready"
    interval = 10
  }

  # TODO: healthcheck envoy

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "kubernetes_manifest" "targetgroupbinding-dns-cache-dns-https" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "dns-cache-https"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "unbound-envoy"
        "port" = "dns-https"
      },
      "targetGroupARN" = aws_lb_target_group.dns-https.arn
    }
  }
}
