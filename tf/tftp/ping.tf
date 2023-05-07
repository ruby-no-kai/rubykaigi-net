resource "aws_s3_object" "ping" {
  bucket        = aws_s3_bucket.tftp.id
  key           = "ping"
  content       = "{\"ok\": true}\n"
  content_type  = "application/json"
  cache_control = "max-age=3600"
}
