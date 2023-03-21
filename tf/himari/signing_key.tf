module "himari_signing_key" {
  #source = "/home/sorah/git/github.com/sorah/himari/himari-aws/lambda/terraform/signing_key"
  source = "github.com/sorah/himari//himari-aws/lambda/terraform/signing_key"

  secret_name = "himari-prd-signing-key"

  rotation_function_arn           = module.himari_functions.secrets_rotation_function_arn
  rotate_automatically_after_days = 20
}
