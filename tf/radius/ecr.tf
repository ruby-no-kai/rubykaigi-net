resource "aws_ecr_repository" "radiusd" {
  name = "radiusd"
}

resource "aws_ecr_lifecycle_policy" "radiusd" {
  repository = aws_ecr_repository.radiusd.name
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

resource "aws_ecr_repository" "freeradius-exporter" {
  name = "freeradius-exporter"
}

resource "aws_ecr_lifecycle_policy" "freeradius-exporter" {
  repository = aws_ecr_repository.freeradius-exporter.name
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
