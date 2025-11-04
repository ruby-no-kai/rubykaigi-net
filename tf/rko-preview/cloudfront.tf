data "aws_cloudfront_origin_request_policy" "Managed-CORS-S3Origin" {
  name = "Managed-CORS-S3Origin"
}
data "aws_cloudfront_cache_policy" "Managed-CachingOptimized" {
  name = "Managed-CachingDisabled"
}

moved {
  from = aws_cloudfront_distribution.dot-net
  to   = aws_cloudfront_distribution.rko-preview
}

resource "aws_cloudfront_distribution" "rko-preview" {
  provider = aws.use1
  comment  = "rko-preview"
  aliases  = ["rko-preview.rubykaigi.net", "*.rko-preview.rubykaigi.net"]

  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.rko-preview-rubykaigi-net.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  logging_config {
    include_cookies = false
    bucket          = "rk-aws-logs.s3.amazonaws.com"
    prefix          = "cf/rko-preview.rubykaigi.net/"
  }

  origin {
    origin_id   = "s3"
    domain_name = aws_s3_bucket.rko-preview.bucket_regional_domain_name
  }

  default_cache_behavior {
    target_origin_id         = "s3"
    cache_policy_id          = data.aws_cloudfront_cache_policy.Managed-CachingOptimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.Managed-CORS-S3Origin.id

    allowed_methods = ["GET", "HEAD", "OPTIONS", ]
    cached_methods  = ["GET", "HEAD"]

    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rko-preview-viewreq.arn
    }
    function_association {
      event_type   = "viewer-response"
      function_arn = aws_cloudfront_function.rko-preview-viewres.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "rko-preview"
  }
}

resource "null_resource" "tsc" {
  triggers = {
    tsdgst = join("", [
      sha256(join("", [for f in fileset("${path.module}/cf_functions", "src/**/*.ts") : filesha256("${path.module}/cf_functions/${f}")])),
      filesha256("${path.module}/cf_functions/pnpm-lock.yaml"),
    ])
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/cf_functions && pnpm i && tsc -b"
  }
}

data "local_file" "rko-preview-viewreq" {
  filename   = "${path.module}/cf_functions/src/viewreq.js"
  depends_on = [null_resource.tsc]
}
data "local_file" "rko-preview-viewres" {
  filename   = "${path.module}/cf_functions/src/viewres.js"
  depends_on = [null_resource.tsc]
}

resource "aws_cloudfront_function" "rko-preview-viewreq" {
  provider = aws.use1
  name     = "rko-preview-viewreq"
  comment  = "rko-preview viewer-request"
  runtime  = "cloudfront-js-2.0"
  publish  = true
  code     = "${replace(data.local_file.rko-preview-viewreq.content, "/(?m)^export function handler/", "function handler")}\n// 1"
}

resource "aws_cloudfront_function" "rko-preview-viewres" {
  provider = aws.use1
  name     = "rko-preview-viewres"
  comment  = "rko-preview viewer-response"
  runtime  = "cloudfront-js-2.0"
  publish  = true
  code     = "${replace(data.local_file.rko-preview-viewres.content, "/(?m)^export function handler/", "function handler")}\n// 1"
}
