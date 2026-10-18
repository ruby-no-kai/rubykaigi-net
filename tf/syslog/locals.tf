locals {
  syslog_target_port         = 5140
  syslog_healthz_target_port = 10068

  nlb_subnets = {
    main-private-c = data.aws_subnet.main-private-c,
    main-private-d = data.aws_subnet.main-private-d,
  }
  nlb_ips = [for s in local.nlb_subnets : cidrhost(s.cidr_block, 14)]
}
