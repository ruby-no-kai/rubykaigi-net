# State migration from sponsor-app/tf to module-based structure

# ECR (shared, goes to prd module with [0])
moved {
  from = aws_ecr_repository.app
  to   = module.prd.aws_ecr_repository.app[0]
}

moved {
  from = aws_ecr_lifecycle_policy.app
  to   = module.prd.aws_ecr_lifecycle_policy.app[0]
}

# S3 - Production bucket and configs
moved {
  from = aws_s3_bucket.files-prd
  to   = module.prd.aws_s3_bucket.files
}

moved {
  from = aws_s3_bucket_public_access_block.files["prd"]
  to   = module.prd.aws_s3_bucket_public_access_block.files
}

moved {
  from = aws_s3_bucket_versioning.files["prd"]
  to   = module.prd.aws_s3_bucket_versioning.files
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.files["prd"]
  to   = module.prd.aws_s3_bucket_lifecycle_configuration.files
}

moved {
  from = aws_s3_bucket_accelerate_configuration.files["prd"]
  to   = module.prd.aws_s3_bucket_accelerate_configuration.files
}

moved {
  from = aws_s3_bucket_cors_configuration.files-prd
  to   = module.prd.aws_s3_bucket_cors_configuration.files
}

# S3 - Development bucket and configs
moved {
  from = aws_s3_bucket.files-dev
  to   = module.dev.aws_s3_bucket.files
}

moved {
  from = aws_s3_bucket_public_access_block.files["dev"]
  to   = module.dev.aws_s3_bucket_public_access_block.files
}

moved {
  from = aws_s3_bucket_versioning.files["dev"]
  to   = module.dev.aws_s3_bucket_versioning.files
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.files["dev"]
  to   = module.dev.aws_s3_bucket_lifecycle_configuration.files
}

moved {
  from = aws_s3_bucket_accelerate_configuration.files["dev"]
  to   = module.dev.aws_s3_bucket_accelerate_configuration.files
}

moved {
  from = aws_s3_bucket_cors_configuration.files-dev
  to   = module.dev.aws_s3_bucket_cors_configuration.files
}

# SQS (production only)
moved {
  from = aws_sqs_queue.activejob-prd
  to   = module.prd.aws_sqs_queue.activejob[0]
}

moved {
  from = aws_sqs_queue.activejob-dlq-prd
  to   = module.prd.aws_sqs_queue.activejob-dlq[0]
}

# App Runner (production only)
moved {
  from = aws_apprunner_service.prd
  to   = module.prd.aws_apprunner_service.prd[0]
}

# CloudFront (production only)
moved {
  from = aws_cloudfront_distribution.prd
  to   = module.prd.aws_cloudfront_distribution.prd[0]
}

# CloudWatch Log Groups (shared, goes to prd module with [0])
moved {
  from = aws_cloudwatch_log_group.worker
  to   = module.prd.aws_cloudwatch_log_group.worker[0]
}

moved {
  from = aws_cloudwatch_log_group.batch
  to   = module.prd.aws_cloudwatch_log_group.batch[0]
}

# IAM - Production App Role
moved {
  from = aws_iam_role.SponsorApp
  to   = module.prd.aws_iam_role.SponsorApp
}

moved {
  from = aws_iam_role_policy.SponsorApp
  to   = module.prd.aws_iam_role_policy.SponsorApp
}

# IAM - Development App Role
moved {
  from = aws_iam_role.SponsorAppDev
  to   = module.dev.aws_iam_role.SponsorApp
}

moved {
  from = aws_iam_role_policy.SponsorAppDev
  to   = module.dev.aws_iam_role_policy.SponsorApp
}

# IAM - Production User Role (S3 uploads)
moved {
  from = aws_iam_role.SponsorAppUser
  to   = module.prd.aws_iam_role.SponsorAppUser
}

moved {
  from = aws_iam_role_policy.SponsorAppUser
  to   = module.prd.aws_iam_role_policy.SponsorAppUser
}

# IAM - Development User Role (S3 uploads)
moved {
  from = aws_iam_role.SponsorAppDevUser
  to   = module.dev.aws_iam_role.SponsorAppUser
}

moved {
  from = aws_iam_role_policy.SponsorAppDevUser
  to   = module.dev.aws_iam_role_policy.SponsorAppUser
}

# IAM - App Runner Access Role (ECR pull)
moved {
  from = aws_iam_role.app-runner-access
  to   = module.prd.aws_iam_role.app-runner-access[0]
}

moved {
  from = aws_iam_role_policy.app-runner-access
  to   = module.prd.aws_iam_role_policy.app-runner-access[0]
}

# IAM - ECS Task Execution Role (shared, goes to prd module with [0])
moved {
  from = aws_iam_role.EcsExecSponsorApp
  to   = module.prd.aws_iam_role.EcsExecSponsorApp[0]
}

moved {
  from = aws_iam_role_policy.EcsExecSponsorApp
  to   = module.prd.aws_iam_role_policy.EcsExecSponsorApp[0]
}

# IAM - GitHub Actions Deployment Role (shared, goes to prd module with [0])
moved {
  from = aws_iam_role.GhaSponsorDeploy
  to   = module.prd.aws_iam_role.GhaSponsorDeploy[0]
}

moved {
  from = aws_iam_role_policy.GhaSponsorDeploy
  to   = module.prd.aws_iam_role_policy.GhaSponsorDeploy[0]
}
