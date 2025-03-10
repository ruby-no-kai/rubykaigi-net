locals {
  app_ref    = "68824faac156e2b757d51e5a663238f4a4a197de-arm64"
  event_slug = "rubykaigi/2025"
  environment = {
    RACK_ENV   = "production"
    S3_BUCKET  = aws_s3_bucket.attendee-gate.bucket
    S3_KEY     = "prd/${local.event_slug}.sqlite3"
    SSM_PREFIX = "/attendee-gate/prd/"
  }
}
