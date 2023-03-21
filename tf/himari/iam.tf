module "himari_iam" {
  #source = "/home/sorah/git/github.com/sorah/himari/himari-aws/lambda/terraform/iam"
  source = "github.com/sorah/himari//himari-aws/lambda/terraform/iam"

  role_name           = "LambdaHimari"
  dynamodb_table_name = local.dynamodb_table_name

  secrets_rotation_function_arn = module.himari_functions.secrets_rotation_function_arn

  secret_arns = toset([
    module.himari_signing_key.secret_arn,
    aws_secretsmanager_secret.params.arn,
  ])
}
