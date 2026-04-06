locals {
  app_ref    = "aac79283f977be18b36699c86c6fe016b56118a7-arm64"
  event_slug = "rubykaigi/2026"
  environment = {
    RACK_ENV   = "production"
    S3_BUCKET  = aws_s3_bucket.attendee-gate.bucket
    S3_KEY     = "prd/${local.event_slug}.sqlite3"
    SSM_PREFIX = "/attendee-gate/prd/"
  }
}
