locals {
  azs = toset(["ap-northeast-1c", "ap-northeast-1d"])
}

data "aws_vpc" "main" {
  id = "vpc-004eca6fe0bf3494d"
}

data "aws_subnet" "main-private" {
  for_each = local.azs

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "availability-zone"
    values = [each.key]
  }
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}
