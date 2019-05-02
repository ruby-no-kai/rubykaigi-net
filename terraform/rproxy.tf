#resource "aws_lb" "rproxy" {
#  name = "rproxy"
#  internal = false
#
#  security_groups = ["${aws_security_group.default.id}", "${aws_security_group.elb_http.id}"]
#  subnets = ["${local.public_subnet_ids}"]
#
#  idle_timeout = 30
#  enable_deletion_protection = false
#}
#resource "aws_lb_listener" "rproxy_80" {
#  load_balancer_arn = "${aws_lb.rproxy.arn}"
#  port = 80
#  protocol = "HTTP"
#
#  default_action {
#    target_group_arn = "${aws_lb_target_group.rproxy.arn}"
#    type = "forward"
#  }
#}
#resource "aws_lb_listener" "rproxy_443" {
#  load_balancer_arn = "${aws_lb.rproxy.arn}"
#  port = 443
#  protocol = "HTTPS"
#  certificate_arn = "arn:aws:acm:ap-northeast-1:005216166247:certificate/0040b456-2e53-47c6-9067-820b2f764ba8"
#  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
#
#  default_action {
#    target_group_arn = "${aws_lb_target_group.rproxy.arn}"
#    type = "forward"
#  }
#}
#
#resource "aws_lb_target_group" "rproxy" {
#  name = "rproxy"
#  port = 80
#  protocol = "HTTP"
#  vpc_id = "${aws_vpc.main.id}"
#  target_type = "instance"
#
#  deregistration_delay = 30
#  slow_start = 0
#
#  health_check {
#    path = "/httpd_alived"
#    interval = 6
#    healthy_threshold = 3
#    unhealthy_threshold = 2
#    matcher = "200"
#  }
#}
