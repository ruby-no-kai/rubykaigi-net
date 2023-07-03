#resource "aws_vpn_connection" "rk23-nrt" {
#  vpn_gateway_id      = aws_vpn_gateway.main.id
#  customer_gateway_id = aws_customer_gateway.rk23-nrt.id
#  type                = aws_customer_gateway.rk23-nrt.type
#  static_routes_only  = false
#
#  tunnel1_ike_versions = ["ikev2"]
#  tunnel2_ike_versions = ["ikev2"]
#
#  tags = {
#    Name      = "rk23-nrt"
#    Project   = "rk23net"
#    Component = "core/vpc"
#  }
#}
#
#resource "aws_customer_gateway" "rk23-nrt" {
#  bgp_asn    = 65002
#  ip_address = "117.102.186.171"
#  type       = "ipsec.1"
#
#  tags = {
#    Name      = "rk23-nrt"
#    Project   = "rk23net"
#    Component = "core/vpc"
#  }
#}
