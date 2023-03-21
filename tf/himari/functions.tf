module "himari_functions" {
  #source = "/home/sorah/git/github.com/sorah/himari/himari-aws/lambda/terraform/functions"
  source = "github.com/sorah/himari//himari-aws/lambda/terraform/functions"

  iam_role_arn = module.himari_iam.role_arn
  image_url    = module.himari_image.image.url

  dynamodb_table_name  = local.dynamodb_table_name
  function_name_prefix = "himari-prd"

  config_ru = file("${path.module}/config.ru")

  environment = {
    HIMARI_SIGNING_KEY_ARN   = module.himari_signing_key.secret_arn
    HIMARI_SECRET_PARAMS_ARN = aws_secretsmanager_secret.params.arn
  }
}

locals {
  dynamodb_table_name = "himari-prd"
}
