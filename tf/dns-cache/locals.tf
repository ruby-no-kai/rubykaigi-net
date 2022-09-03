locals {
  dns_cache_dns_target_port = 10053
  dns_cache_healthz_target_port = 9167

  nlb_subnets = [
    data.aws_subnet.main-private-c,
    data.aws_subnet.main-private-d,
  ]
}
