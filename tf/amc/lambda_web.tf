resource "aws_secretsmanager_secret" "params" {
  name = "amc/params"
}

resource "aws_lambda_function" "amc-web" {
  function_name = "amc-web"

  filename         = "${path.module}/amc.zip"
  source_code_hash = data.archive_file.amc.output_base64sha256
  handler          = "web.Main.handle"
  runtime          = "ruby2.7"
  architectures    = ["arm64"]

  role = aws_iam_role.amc.arn

  memory_size = 128
  timeout     = 15

  environment {
    variables = {
      RACK_ENV = "production"

      AMC_EXPECT_ISS        = "https://idp.rubykaigi.net"
      AMC_SELF_ISS          = "https://amc.rubykaigi.net"
      AMC_PROVIDER_ID       = "amc.rubykaigi.net"
      AMC_SIGNING_KEY_ARN   = aws_secretsmanager_secret.signing_key.arn
      AMC_SECRET_PARAMS_ARN = aws_secretsmanager_secret.params.arn
      AMC_SESSION_DURATION  = tostring(3600 * 12)
    }
  }
}

resource "aws_lambda_function_url" "amc-web" {
  function_name      = aws_lambda_function.amc-web.function_name
  authorization_type = "NONE"
}

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

resource "aws_cloudfront_distribution" "amc-rubykaigi-net" {
  provider        = aws.use1
  enabled         = true
  is_ipv6_enabled = true
  comment         = "amc"
  aliases         = ["amc.rubykaigi.net"]

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.use1-wild-rk-n.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  logging_config {
    include_cookies = false
    bucket          = "rk-aws-logs.s3.amazonaws.com"
    prefix          = "cf/amc.rubykaigi.net/"
  }

  origin {
    origin_id   = "amc-function-url"
    domain_name = replace(replace(aws_lambda_function_url.amc-web.function_url, "https://", ""), "/", "")
    custom_header {
      name  = "X-Forwarded-Host"
      value = "amc.rubykaigi.net"
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
    path_pattern     = "/public/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "amc-function-url"

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

    target_origin_id         = "amc-function-url"
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
