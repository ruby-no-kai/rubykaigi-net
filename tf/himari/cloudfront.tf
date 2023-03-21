data "aws_acm_certificate" "use1-wild-rk-n" {
  provider = aws.use1
  domain   = "*.rubykaigi.net"
}

data "aws_cloudfront_origin_request_policy" "Managed-AllViewerExceptHostHeader" {
  name = "Managed-AllViewerExceptHostHeader"
}
data "aws_cloudfront_cache_policy" "Managed-CachingDisabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "idp-rubykaigi-net" {
  provider        = aws.use1
  enabled         = true
  is_ipv6_enabled = true
  comment         = "himari"
  aliases         = ["idp.rubykaigi.net"]

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.use1-wild-rk-n.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  logging_config {
    include_cookies = false
    bucket          = "rk-aws-logs.s3.amazonaws.com"
    prefix          = "cf/idp.rubykaigi.net/"
  }

  origin {
    origin_id   = "himari-function-url"
    domain_name = replace(replace(module.himari_functions.function_url, "https://", ""), "/", "")
    custom_header {
      name  = "X-Forwarded-Host"
      value = "idp.rubykaigi.net"
    }
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 30
      origin_read_timeout      = 35
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/public/index.css"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "himari-function-url"

    forwarded_values {
      query_string = true
      headers      = []
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 31536000

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/public/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "himari-function-url"

    forwarded_values {
      query_string = true
      headers      = []
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 31536000
    max_ttl     = 31536000

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id         = "himari-function-url"
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


