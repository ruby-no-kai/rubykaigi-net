resource "aws_lb" "nlb" {
  name               = "radius-${substr(uuid(), 0, 10)}"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for s in local.nlb_subnets : s.id]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_lb_listener" "radius" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "1812"
  protocol          = "TCP_UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.radius.arn
  }
}

resource "aws_lb_target_group" "radius" {
  name        = "radius-radius-${substr(uuid(), 0, 10)}"
  target_type = "ip"
  port        = "1812"
  protocol    = "TCP_UDP"
  vpc_id      = data.aws_vpc.main.id

  connection_termination = true
  deregistration_delay   = 10

  health_check {
    protocol = "HTTP"
    port     = 9812
    path     = "/metrics"
    interval = 40
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "kubernetes_manifest" "targetgroupbinding-radius-radius" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "radius"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "radius"
        "port" = "radius"
      },
      "targetGroupARN" = aws_lb_target_group.radius.arn
    }
  }
}
