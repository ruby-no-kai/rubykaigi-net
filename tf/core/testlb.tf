resource "aws_lb" "testlb" {
  name               = "himaritestlb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [
    aws_security_group.elb_http.id,
  ]

  subnets = [
    aws_subnet.c_public.id,
    aws_subnet.d_public.id,
  ]

  ip_address_type = "dualstack"
  access_logs {
    bucket  = "rk-aws-logs"
    prefix  = "elb/himaritestlb"
    enabled = true
  }
}

resource "aws_lb_listener" "testlb-http" {
  load_balancer_arn = aws_lb.testlb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "testlb-https" {
  load_balancer_arn = aws_lb.testlb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = aws_acm_certificate_validation.rubykaigi-net.certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "🥷 ?"
      status_code  = 404
    }
  }
}

resource "aws_route53_record" "testlb" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value

  name = "test-lb.rubykaigi.net."
  type = "CNAME"
  ttl  = 60
  records = [
    aws_lb.testlb.dns_name,
  ]
}

resource "aws_lb_listener_rule" "testlb-rule" {
  listener_arn = aws_lb_listener.testlb-https.arn
  priority     = 100
  condition {
    host_header {
      values = ["test-lb.rubykaigi.net"]
    }
  }
  action {
    type = "authenticate-oidc"
    authenticate_oidc {
      authorization_endpoint     = "https://idp.rubykaigi.net/oidc/authorize"
      token_endpoint             = "https://idp.rubykaigi.net/public/oidc/token"
      user_info_endpoint         = "https://idp.rubykaigi.net/public/oidc/userinfo"
      client_id                  = "testlb"
      client_secret              = "testlbsecret"
      issuer                     = "https://idp.rubykaigi.net"
      scope                      = "openid"
      on_unauthenticated_request = "authenticate"
      session_timeout            = 3600
    }
  }
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "<!DOCTYPE html><html lang=en><head><meta charset=utf-8><body><img src=\"https://img.sorah.jp/x/20220824_054329_Wx7mcpRweD.png\">"
      status_code  = 200
    }
  }
}

