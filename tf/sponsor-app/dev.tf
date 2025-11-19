module "dev" {
  source = "../../../sponsor-app/tf"

  providers = {
    aws            = aws
    aws.cloudfront = aws.use1
    aws.files      = aws.apne1
  }

  environment     = "dev"
  name            = "dev"
  sqs_name_suffix = "dev"
  iam_role_prefix = "SponsorAppDev"

  s3_bucket_name = "rk-sponsorship-files-dev"
  s3_cors_origins = [
    "http://localhost:13000",
    "http://localhost:13010",
    "http://localhost:3000",
    "https://amc.rubykaigi.net",
  ]

  enable_cloudfront       = false
  enable_sqs              = false
  enable_app              = false
  amc_oidc_domain         = "amc.rubykaigi.net"
  enable_shared_resources = false
  ssm_parameter_prefix    = "/sponsor-app-dev/"

  github_actions_sub = "repo:ruby-no-kai/sponsor-app:ref:refs/heads/master"
}
