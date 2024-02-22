module "amc" {
  source = "github.com/sorah/himari2amc?ref=c3aef162c21a8e23e0a8e07f1720eb26896cca2f"
  #source = "/home/sorah/git/github.com/sorah/himari2amc"

  name                       = "amc"
  iam_role_name              = "LambdaAmc"
  idp_issuer                 = "https://idp.rubykaigi.net"
  domain_name                = "amc.rubykaigi.net"
  session_duration           = 3600
  cloudfront_log_bucket      = "rk-aws-logs.s3.amazonaws.com"
  cloudfront_log_prefix      = "cf/amc.rubykaigi.net/"
  cloudfront_certificate_arn = data.aws_acm_certificate.use1-wild-rk-n.arn

  environment_variables = {
    AMC_ALT_CLIENT_IDS           = "a94519af-8c51-4f8b-af3a-a58130415096",
    AMC_SESSION_DURATION_CONSOLE = tostring(3600 * 12)
  }

  header_html = "<img height=310 width=310 src='https://img.sorah.jp/ba-01-09.png' alt=''>"
  footer_html = <<-EOH
    <p><small>
    Not seeing a correct role? Try <a href="/auth/himari?prompt=login">Reauthenticate</a>. |
    <a href="https://rubykaigi.esa.io/posts/813">Help</a> |
    <a href="https://github.com/ruby-no-kai/rubykaigi-nw/tree/master/tf/amc">Deployment</a>
    </small></p>
  EOH
}

