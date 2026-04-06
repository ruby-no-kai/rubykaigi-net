resource "aws_s3_bucket" "rk-aws-logs" {
  bucket = "rk-aws-logs"

  tags = {
    Name      = "rk-aws-logs"
    Component = "syslog"
  }
}
resource "aws_s3_bucket_public_access_block" "rk-aws-logs" {
  bucket = aws_s3_bucket.rk-aws-logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_policy" "rk-aws-logs" {
  bucket = aws_s3_bucket.rk-aws-logs.id
  policy = data.aws_iam_policy_document.rk-aws-logs.json
}
data "aws_iam_policy_document" "rk-aws-logs" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::582318560864:root"] # ELB ap-northeast-1
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.rk-aws-logs.arn}/elb/*",
    ]
  }
}

import {
  id = "rk-aws-logs"
  to = aws_s3_bucket.rk-aws-logs
}
import {
  id = "rk-aws-logs"
  to = aws_s3_bucket_policy.rk-aws-logs
}
