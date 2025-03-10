data "aws_acm_certificate" "rubykaigi-net" {
  domain      = "*.rubykaigi.net"
  statuses    = ["ISSUED"]
  most_recent = true
}
