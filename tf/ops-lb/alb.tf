resource "aws_lb" "common" {
  name               = "rknw-common"
  load_balancer_type = "application"
  internal           = true

  security_groups = [
    aws_security_group.ops-lb.id,
  ]

  subnets = [for subnet in data.aws_subnet.main-private : subnet.id]

  ip_address_type = "dualstack"

  access_logs {
    bucket  = "rk-aws-logs"
    prefix  = "elb/rknw-common"
    enabled = true
  }
}

resource "aws_lb_listener" "common-http" {
  load_balancer_arn = aws_lb.common.arn
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

resource "aws_lb_listener" "common-https" {
  load_balancer_arn = aws_lb.common.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.rubykaigi-net.arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "🏯🗻 ?"
      status_code  = 404
    }
  }
}

resource "aws_globalaccelerator_accelerator" "common" {
  name            = "rknw-common-accel"
  ip_address_type = "DUAL_STACK"
  enabled         = true
}

resource "aws_globalaccelerator_listener" "common-http" {
  accelerator_arn = aws_globalaccelerator_accelerator.common.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"
  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_listener" "common-https" {
  accelerator_arn = aws_globalaccelerator_accelerator.common.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"
  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "common-http" {
  listener_arn          = aws_globalaccelerator_listener.common-http.id
  endpoint_group_region = "ap-northeast-1"
  health_check_port     = 80
  endpoint_configuration {
    endpoint_id                    = aws_lb.common.arn
    client_ip_preservation_enabled = true
    weight                         = 1
  }
}

resource "aws_globalaccelerator_endpoint_group" "common-https" {
  listener_arn          = aws_globalaccelerator_listener.common-https.id
  endpoint_group_region = "ap-northeast-1"
  health_check_port     = 443
  endpoint_configuration {
    endpoint_id                    = aws_lb.common.arn
    client_ip_preservation_enabled = true
    weight                         = 1
  }
}

resource "aws_route53_record" "ops-lb_rubykaigi_net-public-CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_public.id

  name = "ops-lb.rubykaigi.net."
  type = "CNAME"
  ttl  = 60
  records = [
    "${replace(aws_globalaccelerator_accelerator.common.dns_name, ".awsglobalaccelerator.com", ".dualstack.awsglobalaccelerator.com")}.",
  ]
}

# cannot use IPv6 address here because we have no IPv6 private connection
resource "aws_route53_record" "ops-lb_rubykaigi_net-private-A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.id

  name = "ops-lb.rubykaigi.net."
  type = "A"
  alias {
    name                   = aws_lb.common.dns_name
    zone_id                = aws_lb.common.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ops-lb-public_rubykaigi_net-public-CNAME" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value

  name = "ops-lb-public.rubykaigi.net."
  type = "CNAME"
  ttl  = 60
  records = [
    "${replace(aws_globalaccelerator_accelerator.common.dns_name, ".awsglobalaccelerator.com", ".dualstack.awsglobalaccelerator.com")}.",
  ]
}

resource "aws_route53_record" "ops-lb-internal_rubykaigi_net-A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value

  name = "ops-lb-internal.rubykaigi.net."
  type = "A"
  alias {
    name                   = aws_lb.common.dns_name
    zone_id                = aws_lb.common.zone_id
    evaluate_target_health = true
  }
}
