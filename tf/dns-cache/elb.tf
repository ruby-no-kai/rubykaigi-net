resource "aws_lb" "nlb" {
  name               = "dns-cache-${substr(uuid(), 0, 10)}"
  internal           = true
  load_balancer_type = "network"
  subnets            = [
    data.aws_subnet.main-private-c.id,
    data.aws_subnet.main-private-d.id,
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [name]
  }
}

##

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
    port     = local.dns_cache_healthz_target_port
    path     = "/healthz"
    interval = 10
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [name]
  }
}

resource "kubernetes_manifest" "targetgroupbinding-dns-cache-dns" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata"   = {
      "name"      = "dns-cache"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef"     = {
        "name" = "unbound"
        "port" = "dns"
      },
      "targetGroupARN" = aws_lb_target_group.dns.arn
    }
  }
}
