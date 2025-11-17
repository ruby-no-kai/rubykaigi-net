module "prd" {
  source = "../../../sponsor-app/tfmod"

  providers = {
    aws       = aws
    aws.use1  = aws.use1
    aws.apne1 = aws.apne1
  }

  environment               = "production"
  service_name              = "sponsor-app"
  sqs_name_suffix           = "prd"
  iam_role_prefix           = "SponsorApp"
  iam_apprunner_access_name = "AppraSponsorApp"

  s3_bucket_name  = "rk-sponsorship-files-prd"
  s3_cors_origins = ["https://sponsorships.rubykaigi.org"]

  enable_cloudfront = true
  enable_sqs        = true
  enable_apprunner  = true
  enable_amc_oidc   = false
  enable_shared_resources = true

  app_domain            = "sponsorships.rubykaigi.org"
  certificate_arn       = data.aws_acm_certificate.use1-sponsorships-rk-o.arn
  cloudfront_log_bucket = "rk-aws-logs.s3.amazonaws.com"
  cloudfront_log_prefix = "cf/sponsorships.rubykaigi.org/"
  cloudfront_comment    = "sponsor-app"

  github_actions_sub = "repo:ruby-no-kai/sponsor-app:environment:production"
}
