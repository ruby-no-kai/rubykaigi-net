data "aws_acm_certificate" "use1-wild-rk-n" {
  provider = aws.use1
  domain   = "*.rubykaigi.net"
}

