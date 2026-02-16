resource "aws_ecr_repository" "netbox" {
  name = "netbox"

  tags = {
    SkopeoCopy = "1"
  }
}

resource "aws_ecr_lifecycle_policy" "netbox" {
  repository = aws_ecr_repository.netbox.name
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

data "aws_lambda_function" "skopeo-copy" {
  provider      = aws.apne1
  function_name = "skopeo-copy"
}

locals {
  netbox_image_tag = "cee56822d5091e8534bb55d7a6e8f05f9f38d4e3"
}

resource "aws_lambda_invocation" "skopeo-copy-netbox" {
  provider      = aws.apne1
  function_name = data.aws_lambda_function.skopeo-copy.function_name

  input = jsonencode({
    skopeo_copy = {
      src = "docker://ghcr.io/sorah/nkmi-netbox:${local.netbox_image_tag}"
      dst = "docker://${aws_ecr_repository.netbox.repository_url}:${local.netbox_image_tag}"
    }
  })

  triggers = {
    src = "docker://ghcr.io/sorah/nkmi-netbox:${local.netbox_image_tag}"
    dst = "docker://${aws_ecr_repository.netbox.repository_url}:${local.netbox_image_tag}"
  }
}
