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
