resource "aws_ecr_repository" "skopeo-copy" {
  name                 = "skopeo-copy"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  image_tag_mutability_exclusion_filter {
    filter      = "latest"
    filter_type = "WILDCARD"
  }
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
