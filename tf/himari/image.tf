moved {
  from = module.himari_image.aws_ecr_repository.repo
  to   = aws_ecr_repository.himari-lambda
}

moved {
  from = module.himari_image.aws_ecr_lifecycle_policy.repo
  to   = aws_ecr_lifecycle_policy.himari-lambda
}

moved {
  from = module.himari_image.aws_ecr_repository_policy.repo-lambda
  to   = aws_ecr_repository_policy.himari-lambda
}

resource "aws_ecr_repository" "himari-lambda" {
  name = "himari-lambda"

  tags = {
    SkopeoCopy = "1"
  }
}

resource "aws_ecr_lifecycle_policy" "himari-lambda" {
  repository = aws_ecr_repository.himari-lambda.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 10
        description  = "expire old images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "himari-lambda-ecr" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
  }
}

resource "aws_ecr_repository_policy" "himari-lambda" {
  repository = aws_ecr_repository.himari-lambda.name
  policy     = data.aws_iam_policy_document.himari-lambda-ecr.json
}

data "aws_lambda_function" "skopeo-copy" {
  function_name = "skopeo-copy-unrestricted"
}

locals {
  himari_image_tag = "5b9d6b9bba45eba74eac1f04e4c71bac3fbcbf29"
}

resource "aws_lambda_invocation" "skopeo-copy-himari-lambda" {
  function_name = data.aws_lambda_function.skopeo-copy.function_name

  input = jsonencode({
    skopeo_copy = {
      src           = "docker://public.ecr.aws/sorah/himari-lambda:${local.himari_image_tag}"
      dst           = "docker://${aws_ecr_repository.himari-lambda.repository_url}:${local.himari_image_tag}"
      arch          = "amd64"
    }
  })

  triggers = {
    src = "docker://public.ecr.aws/sorah/himari-lambda:${local.himari_image_tag}"
    dst = "docker://${aws_ecr_repository.himari-lambda.repository_url}:${local.himari_image_tag}"
  }
}
