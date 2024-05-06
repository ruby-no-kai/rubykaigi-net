resource "aws_ecr_repository" "unbound" {
  name = "unbound"
}

resource "aws_ecr_lifecycle_policy" "unbound" {
  repository = aws_ecr_repository.unbound.name
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


resource "aws_ecr_repository" "dnscollector" {
  name = "dnscollector"
}

resource "aws_ecr_lifecycle_policy" "dnscollector" {
  repository = aws_ecr_repository.dnscollector.name
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
