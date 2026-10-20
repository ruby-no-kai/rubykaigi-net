data "aws_iam_outbound_web_identity_federation" "current" {}

module "sts-cat" {
  source = "github.com/sorah/sts-cat//contrib/terraform/aws?ref=v0.4.0"

  function_name   = "sts-cat"
  iam_role_arn    = aws_iam_role.LambdaStsCat.arn
  github_app_id   = "Iv23lioz9mKfZDeMNCei"
  identifier      = "https://sts-cat.rubykaigi.net"
  aws_kms_key_arn = aws_kms_external_key.sts-cat.arn
  architecture    = "arm64"

  # Keep in sync with the module ref above
  source_url    = "https://github.com/sorah/sts-cat/releases/download/v0.4.1/sts-cat-lambda.arm64.zip"
  source_sha512 = "db2c9397f58131cf622a4e1d927d69def35b8722ddcc0ddeb4391bca92dd72730bf3e7bb004067ab49622d9037267d0ebcc9e927eb8e823237db3ca9ef255da8"

  allowed_orgs = ["ruby-no-kai"]
  allowed_issuer_urls = [
    "https://token.actions.githubusercontent.com",
    data.aws_iam_outbound_web_identity_federation.current.issuer_identifier,
  ]
}
