resource "aws_ecr_repository" "attendee-gate" {
  name = "attendee-gate"
}

resource "aws_ecr_lifecycle_policy" "attendee-gate" {
  repository = aws_ecr_repository.attendee-gate.name
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
