resource "aws_ecr_repository" "acmesmith" {
  name = "acmesmith"
}

resource "aws_ecr_lifecycle_policy" "acmesmith" {
  repository = aws_ecr_repository.acmesmith.name
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
