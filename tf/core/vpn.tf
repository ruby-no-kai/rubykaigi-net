locals {
  vpn_ikev2_options = {
    phase1_dh_group_numbers      = [14]
    phase1_encryption_algorithms = ["AES256-GCM-16"]
    phase1_integrity_algorithms  = ["SHA2-512"]
    phase1_lifetime_seconds      = 21600
    phase2_dh_group_numbers      = [14]
    phase2_encryption_algorithms = ["AES256"]
    phase2_integrity_algorithms  = ["SHA2-256"]
    phase2_lifetime_seconds      = 3600
  }
}

resource "aws_vpn_connection" "rk24-nrt" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.rk24-nrt.id
  type                = aws_customer_gateway.rk24-nrt.type
  static_routes_only  = false

  tunnel1_ike_versions = ["ikev2"]
  tunnel2_ike_versions = ["ikev2"]

  tunnel1_inside_cidr = "169.254.22.60/30"
  tunnel2_inside_cidr = "169.254.22.64/30"

  tunnel1_phase1_dh_group_numbers      = local.vpn_ikev2_options.phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms = local.vpn_ikev2_options.phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = local.vpn_ikev2_options.phase1_integrity_algorithms
  tunnel1_phase1_lifetime_seconds      = local.vpn_ikev2_options.phase1_lifetime_seconds
  tunnel1_phase2_dh_group_numbers      = local.vpn_ikev2_options.phase2_dh_group_numbers
  tunnel1_phase2_encryption_algorithms = local.vpn_ikev2_options.phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms  = local.vpn_ikev2_options.phase2_integrity_algorithms
  tunnel1_phase2_lifetime_seconds      = local.vpn_ikev2_options.phase2_lifetime_seconds
  tunnel2_phase1_dh_group_numbers      = local.vpn_ikev2_options.phase1_dh_group_numbers
  tunnel2_phase1_encryption_algorithms = local.vpn_ikev2_options.phase1_encryption_algorithms
  tunnel2_phase1_integrity_algorithms  = local.vpn_ikev2_options.phase1_integrity_algorithms
  tunnel2_phase1_lifetime_seconds      = local.vpn_ikev2_options.phase1_lifetime_seconds
  tunnel2_phase2_dh_group_numbers      = local.vpn_ikev2_options.phase2_dh_group_numbers
  tunnel2_phase2_encryption_algorithms = local.vpn_ikev2_options.phase2_encryption_algorithms
  tunnel2_phase2_integrity_algorithms  = local.vpn_ikev2_options.phase2_integrity_algorithms
  tunnel2_phase2_lifetime_seconds      = local.vpn_ikev2_options.phase2_lifetime_seconds

  tags = {
    Name      = "rk24-nrt"
    Project   = "rk25net"
    Component = "core/vpc"
  }
}

resource "aws_customer_gateway" "rk24-nrt" {
  bgp_asn    = 65152
  ip_address = "117.102.186.171"
  type       = "ipsec.1"

  tags = {
    Name      = "rk24-nrt"
    Project   = "rk25net"
    Component = "core/vpc"
  }

  lifecycle {
    create_before_destroy = true
  }
}
