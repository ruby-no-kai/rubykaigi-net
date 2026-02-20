locals {
  app_ref    = "9275adec21697d5046301b31a4988ea178c5b10c-arm64"
  event_slug = "rubykaigi/2026"
  environment = {
    RACK_ENV   = "production"
    S3_BUCKET  = aws_s3_bucket.attendee-gate.bucket
    S3_KEY     = "prd/${local.event_slug}.sqlite3"
    SSM_PREFIX = "/attendee-gate/prd/"
  }
}
