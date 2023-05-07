resource "aws_ecr_repository" "s3tftpd-healthz" {
  name = "s3tftpd-healthz"
}

resource "aws_ecr_lifecycle_policy" "s3tftpd-healthz" {
  repository = aws_ecr_repository.s3tftpd-healthz.name
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
