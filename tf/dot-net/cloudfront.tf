data "aws_acm_certificate" "use1-rk-n" {
  provider = aws.use1
  domain   = "*.rubykaigi.net" # this should contain bare domain (see tf/core/acm.tf)
}

data "aws_cloudfront_origin_request_policy" "Managed-AllViewerExceptHostHeader" {
  name = "Managed-AllViewerExceptHostHeader"
}
data "aws_cloudfront_cache_policy" "Managed-CachingDisabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "dot-net" {
  provider        = aws.use1
  enabled         = true
  is_ipv6_enabled = true
  comment         = "dot-net"
  aliases         = ["rubykaigi.net"]

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.use1-rk-n.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  logging_config {
    include_cookies = false
    bucket          = "rk-aws-logs.s3.amazonaws.com"
    prefix          = "cf/rubykaigi.net/"
  }

  origin {
    origin_id   = "s3website"
    domain_name = aws_s3_bucket_website_configuration.dot-net.website_endpoint
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 30
      origin_read_timeout      = 35
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS", ]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id         = "s3website"
    cache_policy_id          = data.aws_cloudfront_cache_policy.Managed-CachingDisabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.Managed-AllViewerExceptHostHeader.id

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
