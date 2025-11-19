module "prd" {
  source = "../../../sponsor-app/tf"

  providers = {
    aws            = aws
    aws.cloudfront = aws.use1
    aws.files      = aws.apne1
  }

  environment     = "production"
  name            = "prd"
  sqs_name_suffix = "prd"
  iam_role_prefix = "SponsorApp"

  s3_bucket_name  = "rk-sponsorship-files-prd"
  s3_cors_origins = ["https://sponsorships.rubykaigi.org"]

  enable_cloudfront       = true
  enable_sqs              = true
  enable_app              = true
  amc_oidc_domain         = null
  enable_shared_resources = true
  ssm_parameter_prefix    = "/sponsor-app/"

  app_domain            = "sponsorships.rubykaigi.org"
  certificate_arn       = data.aws_acm_certificate.use1-sponsorships-rk-o.arn
  cloudfront_log_bucket = "rk-aws-logs.s3.amazonaws.com"
  cloudfront_log_prefix = "cf/sponsorships.rubykaigi.org/"
  cloudfront_comment    = "sponsor-app"

  github_actions_sub = "repo:ruby-no-kai/sponsor-app:environment:production"

  environments = {
    DATABASE_URL           = "postgres://sponsor-app:@ep-restless-haze-08597983.us-west-2.aws.neon.tech/sponsor-app-prd?sslmode=verify-full&sslrootcert=/etc/ssl/certs/ca-certificates.crt"
    DEFAULT_EMAIL_ADDRESS  = "prd@sponsorships.rubykaigi.org"
    DEFAULT_EMAIL_HOST     = "sponsorships.rubykaigi.org"
    DEFAULT_EMAIL_REPLY_TO = "sponsorships@rubykaigi.org"
    DEFAULT_URL_HOST       = "sponsorships.rubykaigi.org"
    MAILGUN_DOMAIN         = "sponsorships.rubykaigi.org"
    MAILGUN_SMTP_LOGIN     = "postmaster@sponsorships.rubykaigi.org"
    MAILGUN_SMTP_PORT      = "587"
    MAILGUN_SMTP_SERVER    = "smtp.mailgun.org"
    GITHUB_APP_ID          = "20598"
    GITHUB_CLIENT_ID       = "Iv1.94fc104fb1066d82"
    GITHUB_REPO            = "ruby-no-kai/rubykaigi.org"
    SENTRY_DSN             = "https://377e47f99dc740a88afc746c48f6bcd3@sentry.io/1329978"
  }

  secrets = {
    DATABASE_PASSWORD          = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/sponsor-app/DATABASE_PASSWORD"
    SECRET_KEY_BASE            = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/sponsor-app/SECRET_KEY_BASE"
    GITHUB_CLIENT_PRIVATE_KEY  = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/sponsor-app/GITHUB_CLIENT_PRIVATE_KEY"
    GITHUB_CLIENT_SECRET       = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/sponsor-app/GITHUB_CLIENT_SECRET"
    MAILGUN_API_KEY            = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/sponsor-app/MAILGUN_API_KEY"
    MAILGUN_SMTP_PASSWORD      = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/sponsor-app/MAILGUN_SMTP_PASSWORD"
    SLACK_WEBHOOK_URL          = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/sponsor-app/SLACK_WEBHOOK_URL"
    SLACK_WEBHOOK_URL_FOR_FEED = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/sponsor-app/SLACK_WEBHOOK_URL_FOR_FEED"
    TITO_API_TOKEN             = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/sponsor-app/TITO_API_TOKEN"
  }
}
