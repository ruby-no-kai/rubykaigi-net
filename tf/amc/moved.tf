moved {
  from = aws_cloudfront_distribution.amc-rubykaigi-net
  to   = module.amc.aws_cloudfront_distribution.amc
}
moved {
  from = aws_iam_role.amc
  to   = module.amc.aws_iam_role.amc
}
moved {
  from = aws_iam_role_policy.amc-params
  to   = module.amc.aws_iam_role_policy.amc-params
}
moved {
  from = aws_iam_role_policy.amc-signingkey
  to   = module.amc.aws_iam_role_policy.amc-signingkey
}
moved {
  from = aws_iam_role_policy_attachment.amc-AWSLambdaBasicExecutionRole
  to   = module.amc.aws_iam_role_policy_attachment.amc-AWSLambdaBasicExecutionRole
}
moved {
  from = aws_lambda_function.amc-web
  to   = module.amc.aws_lambda_function.amc-web
}
moved {
  from = aws_lambda_function.signing_key_rotation
  to   = module.amc.aws_lambda_function.signing_key_rotation
}
moved {
  from = aws_lambda_function_url.amc-web
  to   = module.amc.aws_lambda_function_url.amc-web
}
moved {
  from = aws_lambda_permission.signing_key_rotation
  to   = module.amc.aws_lambda_permission.signing_key_rotation
}
moved {
  from = aws_secretsmanager_secret.params
  to   = module.amc.aws_secretsmanager_secret.params
}
moved {
  from = aws_secretsmanager_secret.signing_key
  to   = module.amc.aws_secretsmanager_secret.signing_key
}
moved {
  from = aws_secretsmanager_secret_rotation.signing_key
  to   = module.amc.aws_secretsmanager_secret_rotation.signing_key
}
moved {
  from = null_resource.amc-bundle-install
  to   = module.amc.null_resource.amc-bundle-install
}
moved {
  from = null_resource.amc-revision
  to   = module.amc.null_resource.amc-revision
}
moved {
  from = null_resource.amc-tsc
  to   = module.amc.null_resource.amc-tsc
}
