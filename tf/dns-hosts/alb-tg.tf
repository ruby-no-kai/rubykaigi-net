resource "aws_lb_target_group" "common-wlc" {
  name        = "rknw-common-wlc"
  port        = 80
  protocol    = "HTTPS"
  vpc_id      = data.aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled  = true
    path     = "/"
    protocol = "HTTPS"
  }

  deregistration_delay = 10
}

resource "aws_lb_target_group_attachment" "common-wlc" {
  for_each          = aws_route53_record.host_sys_wlc-01_venue_rubykaigi_net_A.records
  target_group_arn  = aws_lb_target_group.common-wlc.arn
  target_id         = each.value
  port              = 443
  availability_zone = "all"
}
