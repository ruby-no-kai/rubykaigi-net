resource "aws_s3_bucket" "rk-am-i-not-at" {
  bucket = "am-i-not-at-rubykaigi"
}

data "aws_iam_policy_document" "rk-am-i-not-at" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.rk-am-i-not-at.arn}/check",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
    condition {
      test     = "NotIpAddress"
      variable = "aws:SourceIp"
      values = [
        "192.50.220.152/29",
        "192.50.220.160/29",
        "2001:0df0:8500:ca00::/56",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "rk-am-i-not-at" {
  bucket = aws_s3_bucket.rk-am-i-not-at.id
  policy = data.aws_iam_policy_document.rk-am-i-not-at.json
}

resource "aws_s3_object" "rk-am-i-not-at-check" {
  bucket        = aws_s3_bucket.rk-am-i-not-at.id
  key           = "check"
  content       = "{\"ok\": true}\n"
  content_type  = "application/json"
  cache_control = "max-age=3600"
}

resource "aws_s3_bucket_cors_configuration" "rk-am-i-not-at" {
  bucket = aws_s3_bucket.rk-am-i-not-at.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 86400 * 365
  }
}
