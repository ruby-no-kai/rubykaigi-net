data "aws_vpc" "main" {
  id = "vpc-0a4e5da322884146d"
}

data "aws_security_group" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "availability-zone"
    values = ["us-west-2c", "us-west-2d"]
  }
  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}
