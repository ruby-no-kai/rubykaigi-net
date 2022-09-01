resource "aws_ecr_repository" "fluentd" {
  name = "fluentd"
}

resource "aws_ecr_lifecycle_policy" "fluentd" {
  repository = aws_ecr_repository.fluentd.name
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
