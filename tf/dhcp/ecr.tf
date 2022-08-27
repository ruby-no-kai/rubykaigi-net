resource "aws_ecr_repository" "kea" {
  name = "kea"
}

resource "aws_ecr_lifecycle_policy" "kea" {
  repository = aws_ecr_repository.kea.name
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
