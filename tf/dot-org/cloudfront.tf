data "aws_acm_certificate" "use1-rk-o" {
  provider = aws.use1
  domain   = "rubykaigi.org"
}

data "aws_cloudfront_origin_request_policy" "Managed-CORS-S3Origin" {
  name = "Managed-CORS-S3Origin"
}
data "aws_cloudfront_cache_policy" "Managed-CachingOptimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "storage" {
  provider        = aws.use1
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"
  comment         = "storage.rubykaigi.org"
  aliases         = ["storage.rubykaigi.org"]

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.use1-rk-o.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  logging_config {
    include_cookies = false
    bucket          = "rk-aws-logs.s3.amazonaws.com"
    prefix          = "cf/storage.rubykaigi.org/"
  }

  origin {
    origin_id   = "s3"
    domain_name = aws_s3_bucket.rubykaigi-public.bucket_regional_domain_name
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id         = "s3"
    cache_policy_id          = data.aws_cloudfront_cache_policy.Managed-CachingOptimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.Managed-CORS-S3Origin.id

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name      = "storage.rubykaigi.org"
    Component = "rubykaigi-public"
  }
}
