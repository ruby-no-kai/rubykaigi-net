data "aws_vpc" "main" {
  id = "vpc-004eca6fe0bf3494d"
}

data "aws_subnet" "main-public-c" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "availability-zone"
    values = ["ap-northeast-1c"]
  }
  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}

data "aws_subnet" "main-onpremises-c" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "availability-zone"
    values = ["ap-northeast-1c"]
  }
  filter {
    name   = "tag:Tier"
    values = ["onpremises"]
  }
}

