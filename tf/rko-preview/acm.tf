resource "aws_acm_certificate" "rko-preview-rubykaigi-net" {
  provider                  = aws.use1
  domain_name               = "*.rko-preview.rubykaigi.net"
  subject_alternative_names = ["*.rko-preview.rubykaigi.net", "rko-preview.rubykaigi.net"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_rko-preview-rubykaigi-net" {
  for_each = {
    for dvo in aws_acm_certificate.rko-preview-rubykaigi-net.domain_validation_options : dvo.domain_name => {
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

  zone_id = data.aws_route53_zone.rubykaigi-net_public.zone_id
}
