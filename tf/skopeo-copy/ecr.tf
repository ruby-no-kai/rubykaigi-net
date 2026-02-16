resource "aws_ecr_repository" "skopeo-copy" {
  name = "skopeo-copy"
}

resource "aws_ecr_lifecycle_policy" "skopeo-copy" {
  repository = aws_ecr_repository.skopeo-copy.name
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
