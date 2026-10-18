locals {
  # Tag of ghcr.io/sorah/glazed-lambda, copied to ECR with skopeo-copy
  image_tag = "6541b4bdb382e1e93aeedbfc8034911b39fde3be"
}

resource "aws_ecr_repository" "glazed-lambda" {
  name = "glazed-lambda"

  tags = {
    SkopeoCopy = "1"
  }
}

resource "aws_ecr_lifecycle_policy" "glazed-lambda" {
  repository = aws_ecr_repository.glazed-lambda.name
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
      },
    ]
  })
}

data "aws_iam_policy_document" "glazed-lambda-ecr" {
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

resource "aws_ecr_repository_policy" "glazed-lambda" {
  repository = aws_ecr_repository.glazed-lambda.name
  policy     = data.aws_iam_policy_document.glazed-lambda-ecr.json
}

data "aws_lambda_function" "skopeo-copy" {
  function_name = "skopeo-copy"
}

resource "aws_lambda_invocation" "skopeo-copy-glazed-lambda" {
  function_name = data.aws_lambda_function.skopeo-copy.function_name

  input = jsonencode({
    skopeo_copy = {
      src  = "docker://ghcr.io/sorah/glazed-lambda:${local.image_tag}"
      dst  = "docker://${aws_ecr_repository.glazed-lambda.repository_url}:${local.image_tag}"
      arch = "amd64"
    }
  })

  triggers = {
    src = "docker://ghcr.io/sorah/glazed-lambda:${local.image_tag}"
    dst = "docker://${aws_ecr_repository.glazed-lambda.repository_url}:${local.image_tag}"
  }
}
