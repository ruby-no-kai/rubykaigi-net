resource "aws_acm_certificate" "rubykaigi-net" {
  domain_name               = "*.rubykaigi.net"
  subject_alternative_names = ["*.rubykaigi.net", "rubykaigi.net"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}
