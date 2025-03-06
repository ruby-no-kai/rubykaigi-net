locals {
  app_ref    = "f8348e05ce5fd0da24b4f972c8cc69d70d3e3281-arm64"
  event_slug = "rubykaigi/2025"
  environment = {
    RACK_ENV   = "production"
    S3_BUCKET  = aws_s3_bucket.attendee-gate.bucket
    S3_KEY     = "prd/${local.event_slug}.sqlite3"
    SSM_PREFIX = "/attendee-gate/prd/"
  }
}
