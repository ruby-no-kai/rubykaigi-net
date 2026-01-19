resource "aws_s3_object" "day" {
  bucket        = aws_s3_bucket.dot-net.id
  key           = "day"
  source        = "${path.module}/day.html"
  content_type  = "text/html"
  cache_control = "max-age=0"
  etag          = filemd5("${path.module}/day.html")
}

resource "aws_s3_object" "days" {
  for_each         = toset(["when", "days"])
  bucket           = aws_s3_bucket.dot-net.id
  key              = each.value
  content          = ""
  cache_control    = "max-age=0"
  website_redirect = "https://rubykaigi.net/day"
}
