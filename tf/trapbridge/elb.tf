# Shares the syslog NLB so devices need a single collector address.
resource "aws_lb_listener" "snmptrap" {
  load_balancer_arn = data.terraform_remote_state.syslog.outputs.nlb_arn
  port              = "162"
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.snmptrap.arn
  }
}

resource "aws_lb_target_group" "snmptrap" {
  name        = "trapbridge-${substr(uuid(), 0, 10)}"
  target_type = "ip"
  port        = local.trapbridge_snmptrap_target_port
  protocol    = "UDP"
  vpc_id      = data.aws_vpc.main.id

  connection_termination = true
  deregistration_delay   = 10

  health_check {
    protocol = "HTTP"
    port     = local.trapbridge_http_target_port
    path     = "/healthz"
    interval = 10
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "kubernetes_manifest" "targetgroupbinding-trapbridge" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "trapbridge"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "trapbridge"
        "port" = "snmptrap"
      },
      "targetGroupARN" = aws_lb_target_group.snmptrap.arn
    }
  }
}
