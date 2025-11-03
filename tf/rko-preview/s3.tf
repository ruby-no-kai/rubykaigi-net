resource "aws_s3_bucket" "rko-preview" {
  bucket = "rko-preview"
  tags = {
    Name = "rko-preview"
  }
}

resource "aws_s3_bucket_public_access_block" "rko-preview" {
  bucket = aws_s3_bucket.rko-preview.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "rko-preview" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.rko-preview.arn}/*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "rko-preview" {
  bucket = aws_s3_bucket.rko-preview.id
  policy = data.aws_iam_policy_document.rko-preview.json

  depends_on = [aws_s3_bucket_public_access_block.rko-preview]
}


