resource "aws_s3_bucket" "infra" {
  bucket = "rk-infra"
}
import {
  id = "rk-infra"
  to = aws_s3_bucket.infra
}

resource "aws_s3_bucket_versioning" "infra" {
  bucket = aws_s3_bucket.infra.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "infra" {
  depends_on = [aws_s3_bucket_versioning.infra]

  bucket = aws_s3_bucket.infra.id

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
}
