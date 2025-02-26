module "dev" {
  #source = "github.com/ruby-no-kai/signage-app//tf"
  source = "/home/sorah/git/github.com/ruby-no-kai/signage-app/tf"

  name_prefix     = "signage-dev"
  iam_role_prefix = "SignageDev"

  app_domain     = "signage-dev.rubykaigi.org"
  cognito_domain = "rk-signage-dev"

  certificate_arn = data.aws_acm_certificate.use1-wild-rk-o.arn

  # himari
  oidc_issuer        = "https://idp.rubykaigi.net"
  oidc_client_id     = "689e0e73-c496-4269-b06c-28ee7d932cee"
  oidc_client_secret = sensitive(random_id.dev_client_secret.id)

  callback_urls = toset(["http://localhost:3000/oauth2callback"])

  cloudfront_log_bucket = "rk-aws-logs.s3.amazonaws.com"
  cloudfront_log_prefix = "cf/signage-dev.rubykaigi.org/"

  manage_config_in_s3 = false
}

resource "aws_route53_record" "dev" {
  for_each = merge([for zone in local.rubykaigi_net_zones : { "${zone}-A" = [zone, "A"], "${zone}-AAAA" = [zone, "AAAA"] }]...)
  name     = "signage-dev-cf.rubykaigi.net."
  zone_id  = each.value[0]
  type     = each.value[1]
  alias {
    name    = module.dev.cloudfront_distribution_domain_name
    zone_id = "Z2FDTNDATAQYW2" # CloudFront https://docs.aws.amazon.com/Route53/latest/APIReference/API_AliasTarget.html
    //
    evaluate_target_health = true
  }
}

resource "random_id" "dev_client_secret" {
  byte_length = 64
}
output "dev_oidc_client_secret" {
  value     = random_id.dev_client_secret.id
  sensitive = true
}

output "dev" {
  value     = module.dev
  sensitive = true
}
