data "aws_s3_bucket" "rk-infra" {
  bucket = "rk-infra"
}

locals {
  # Rendered by ./gen-glazed.rb
  config_path = "${path.module}/../../gen/glazed/glazed.json"
  # Storages and state of glazed; the function may write here.
  s3_prefix = "glazed/"
}

resource "aws_s3_object" "config" {
  bucket       = data.aws_s3_bucket.rk-infra.bucket
  key          = "config/glazed-lambda/glazed.json"
  source       = local.config_path
  source_hash  = filemd5(local.config_path)
  content_type = "application/json"
}
