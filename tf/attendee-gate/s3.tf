resource "aws_s3_bucket" "attendee-gate" {
  bucket = "rk-attendee-gate"
}
resource "aws_s3_bucket_public_access_block" "attendee-gate" {
  bucket = aws_s3_bucket.attendee-gate.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "attendee-gate" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.attendee-gate.arn}/prd/prometheus/*",
      "${aws_s3_bucket.attendee-gate.arn}/dev/prometheus/*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "attendee-gate" {
  bucket     = aws_s3_bucket.attendee-gate.id
  policy     = data.aws_iam_policy_document.attendee-gate.json
  depends_on = [aws_s3_bucket_public_access_block.attendee-gate]
}


