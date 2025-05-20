resource "aws_s3_bucket" "live" {
  bucket = "rk-live-video"
}

resource "aws_s3_bucket_public_access_block" "live" {
  bucket = aws_s3_bucket.live.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "live" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.live.arn}/*/live/*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "live" {
  bucket = aws_s3_bucket.live.id
  policy = data.aws_iam_policy_document.live.json

  depends_on = [aws_s3_bucket_public_access_block.live]
}

resource "aws_s3_bucket_versioning" "live" {
  bucket = aws_s3_bucket.live.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "live" {
  bucket = aws_s3_bucket.live.id

  transition_default_minimum_object_size = "all_storage_classes_128K"

  rule {
    id     = "config"
    status = "Enabled"

    filter {
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.live]
}
