locals {
  app_ref    = "b3e9f767b1b55263f067d514f5197f7c4474620d-arm64"
  event_slug = "rubykaigi/2025"
  environment = {
    RACK_ENV   = "production"
    S3_BUCKET  = aws_s3_bucket.attendee-gate.bucket
    S3_KEY     = "prd/${local.event_slug}.sqlite3"
    SSM_PREFIX = "/attendee-gate/prd/"
  }
}
