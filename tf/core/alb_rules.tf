resource "aws_lb_listener_rule" "common-test" {
  listener_arn = aws_lb_listener.common-https.arn
  priority     = 100
  condition {
    host_header {
      values = ["test.rubykaigi.net"]
    }
  }
  action {
    type = "authenticate-oidc"
    authenticate_oidc {
      authorization_endpoint     = local.alb_oidc.authorization_endpoint
      token_endpoint             = local.alb_oidc.token_endpoint
      user_info_endpoint         = local.alb_oidc.user_info_endpoint
      client_id                  = local.alb_oidc.client_id
      client_secret              = local.alb_oidc.client_secret
      issuer                     = local.alb_oidc.issuer
      on_unauthenticated_request = local.alb_oidc.on_unauthenticated_request
      session_timeout            = local.alb_oidc.session_timeout
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

resource "aws_route53_record" "test_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "test.rubykaigi.net."
  zone_id  = each.value
  type     = "CNAME"
  ttl      = 60
  records  = ["ops-lb.rubykaigi.net."]
}

###

resource "aws_lb_target_group" "common-dex" {
  name        = "rknw-common-dex"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled = true
    path    = "/healthz"
  }

  deregistration_delay = 30
}

resource "aws_lb_listener_rule" "common-dex" {
  listener_arn = aws_lb_listener.common-https.arn
  priority     = 101
  condition {
    host_header {
      values = ["idp.rubykaigi.net", "idp-internal.rubykaigi.net"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.common-dex.arn
  }
}

resource "aws_route53_record" "idp_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "idp.rubykaigi.net."
  zone_id  = each.value
  type     = "CNAME"
  ttl      = 60
  records  = ["ops-lb.rubykaigi.net."]
}

resource "aws_route53_record" "idp-internal_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "idp-internal.rubykaigi.net."
  zone_id  = each.value
  type     = "CNAME"
  ttl      = 60
  records  = ["ops-lb-internal.rubykaigi.net."]
}
