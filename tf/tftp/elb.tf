# sharing nlb with dhcp
data "terraform_remote_state" "dhcp" {
  backend = "s3"
  config = {
    bucket = "rk-infra"
    region = "ap-northeast-1"
    key    = "terraform/nw-dhcp.tfstate"
  }
}

###

resource "aws_lb_listener" "tftp" {
  load_balancer_arn = data.terraform_remote_state.dhcp.outputs.nlb_arn
  port              = "69"
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.s3tftpd.arn
  }
}

resource "aws_lb_target_group" "s3tftpd" {
  name        = "tftp-s3tftpd-${substr(uuid(), 0, 10)}"
  target_type = "ip"
  port        = 69
  protocol    = "UDP"
  vpc_id      = data.aws_vpc.main.id

  connection_termination = true
  deregistration_delay   = 10

  load_balancing_cross_zone_enabled = true

  health_check {
    protocol = "HTTP"
    port     = 8080
    path     = "/ping"
    interval = 10
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "kubernetes_manifest" "targetgroupbinding-tftp-s3tftpd" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "tftp-s3tftpd"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "tftp-s3tftpd"
        "port" = "tftp"
      },
      "targetGroupARN" = aws_lb_target_group.s3tftpd.arn
    }
  }
}

##

resource "aws_lb_listener" "http" {
  load_balancer_arn = data.terraform_remote_state.dhcp.outputs.nlb_arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.envoy.arn
  }
}
resource "aws_lb_listener" "https" {
  load_balancer_arn = data.terraform_remote_state.dhcp.outputs.nlb_arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-0-2021-06" # maximize compatibility
  certificate_arn   = data.aws_acm_certificate.rubykaigi-net.arn
  alpn_policy       = "HTTP1Only"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.envoy.arn
  }
}

resource "aws_lb_target_group" "envoy" {
  name        = "tftp-envoy-${substr(uuid(), 0, 10)}"
  target_type = "ip"
  port        = 80
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.main.id

  connection_termination = true
  deregistration_delay   = 10

  load_balancing_cross_zone_enabled = true

  health_check {
    protocol = "HTTP"
    port     = 9901
    path     = "/ready"
    interval = 10
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "kubernetes_manifest" "targetgroupbinding-tftp-envoy" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "tftp-envoy"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "tftp-envoy"
        "port" = "http"
      },
      "targetGroupARN" = aws_lb_target_group.envoy.arn
    }
  }
}

