resource "aws_dx_gateway" "dxg" {
  name            = "dxg"
  amazon_side_asn = "64512"
}

resource "aws_dx_gateway_association" "dxg_main" {
  dx_gateway_id         = aws_dx_gateway.dxg.id
  associated_gateway_id = aws_vpn_gateway.main.id
}
