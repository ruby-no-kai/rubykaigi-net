resource "aws_lb" "nlb" {
  name               = "syslog-${substr(uuid(), 0, 10)}"
  internal           = true
  load_balancer_type = "network"

  dynamic "subnet_mapping" {
    for_each = tomap(local.nlb_subnets)
    content {
      subnet_id            = subnet_mapping.value.id
      private_ipv4_address = cidrhost(subnet_mapping.value.cidr_block, 14)
    }
  }

  security_groups = [aws_security_group.nlb.id]

  lifecycle {
    ignore_changes = [name]
  }
}

###

resource "aws_lb_listener" "syslog" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "514"
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.syslog.arn
  }
}

resource "aws_lb_target_group" "syslog" {
  name        = "syslog-syslog-${substr(uuid(), 0, 10)}"
  target_type = "ip"
  port        = local.syslog_target_port
  protocol    = "UDP"
  vpc_id      = data.aws_vpc.main.id

  connection_termination = true
  deregistration_delay   = 10

  health_check {
    protocol = "HTTP"
    port     = local.syslog_healthz_target_port
    path     = "/api/plugins.json"
    interval = 10
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "kubernetes_manifest" "targetgroupbinding-syslog-syslog" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "syslog"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "fluentd"
        "port" = "syslog"
      },
      "targetGroupARN" = aws_lb_target_group.syslog.arn
    }
  }
}
