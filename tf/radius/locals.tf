locals {
  dns_cache_dns_target_port             = 10053
  dns_cache_dns_tls_target_port         = 10853
  dns_cache_dns_https_target_port       = 11443
  dns_cache_unbound_healthz_target_port = 9167
  dns_cache_envoy_healthz_target_port   = 9901

  nlb_subnets = {
    main-private-c = data.aws_subnet.main-private-c,
    main-private-d = data.aws_subnet.main-private-d,
  }
}
