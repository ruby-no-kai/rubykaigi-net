# GitHub App private key is imported with sts-cat's contrib/aws-kms-import-pem.rb
resource "aws_kms_external_key" "sts-cat" {
  description = "sts-cat GitHub App key"
  key_spec    = "RSA_2048"
  key_usage   = "SIGN_VERIFY"
  policy      = data.aws_iam_policy_document.sts-cat-kms.json
}

data "aws_iam_policy_document" "sts-cat-kms" {
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_kms_alias" "sts-cat" {
  name          = "alias/sts-cat"
  target_key_id = aws_kms_external_key.sts-cat.id
}
