locals {
  # Pushed from a local build of github.com/sorah/glazed glazed-aws/lambda/Dockerfile
  image_tag = "dev-202610141510"
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
