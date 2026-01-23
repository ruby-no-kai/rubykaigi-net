resource "aws_s3_bucket" "rubykaigi-public" {
  bucket = "rubykaigi-public"
  tags = {
    Name      = "rubykaigi-public"
    Component = "rubykaigi-public"
  }
}

resource "aws_s3_bucket_policy" "rubykaigi-public" {
  bucket = aws_s3_bucket.rubykaigi-public.id
  policy = data.aws_iam_policy_document.rubykaigi-public.json
}

data "aws_iam_policy_document" "rubykaigi-public" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.rubykaigi-public.arn}/*",
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

import {
  id = "rubykaigi-public"
  to = aws_s3_bucket.rubykaigi-public
}
import {
  id = "rubykaigi-public"
  to = aws_s3_bucket_policy.rubykaigi-public
}
