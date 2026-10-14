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
  source_url    = "https://github.com/sorah/sts-cat/releases/download/v0.4.0/sts-cat-lambda.arm64.zip"
  source_sha512 = "0c5c525c47083ea4ede27a9fcd8b54300ed7d8f21c87cdda2e1fddec2ba7de92db2cecde84b526196caeeafd3d6300e650b357978b367d4a58e08c4749dca6c3"

  allowed_orgs = ["ruby-no-kai"]
  allowed_issuer_urls = [
    "https://token.actions.githubusercontent.com",
    data.aws_iam_outbound_web_identity_federation.current.issuer_identifier,
  ]
}
