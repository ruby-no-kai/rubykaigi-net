resource "aws_acm_certificate" "rubykaigi-net" {
  domain_name               = "*.rubykaigi.net"
  subject_alternative_names = ["*.rubykaigi.net", "rubykaigi.net"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "rubykaigi-net_use1" {
  provider                  = aws.use1
  domain_name               = "*.rubykaigi.net"
  subject_alternative_names = ["*.rubykaigi.net", "rubykaigi.net"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_rubykaigi-net" {
  for_each = {
    for dvo in aws_acm_certificate.rubykaigi-net.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type

  zone_id = aws_route53_zone.rubykaigi-net_public.zone_id

}

resource "aws_acm_certificate_validation" "rubykaigi-net" {
  certificate_arn         = aws_acm_certificate.rubykaigi-net.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_rubykaigi-net : record.fqdn]
}
