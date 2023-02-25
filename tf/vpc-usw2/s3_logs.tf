resource "aws_s3_bucket" "rk-aws-logs-usw2" {
  bucket = "rk-aws-logs-usw2"
}
resource "aws_s3_bucket_public_access_block" "rk-aws-logs-usw2" {
  bucket = aws_s3_bucket.rk-aws-logs-usw2.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_policy" "rk-aws-logs-usw2" {
  bucket = aws_s3_bucket.rk-aws-logs-usw2.id
  policy = data.aws_iam_policy_document.rk-aws-logs-usw2.json
}
data "aws_iam_policy_document" "rk-aws-logs-usw2" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::797873946194:root"] # ELB us-west-2
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.rk-aws-logs-usw2.arn}/elb/*",
    ]
  }
}
