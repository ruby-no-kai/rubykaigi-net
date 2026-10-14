data "aws_vpc" "main" {
  id = "vpc-004eca6fe0bf3494d"
}

# NAT for AWS APIs, and the VPN gateway for the devices
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}

resource "aws_security_group" "glazed" {
  name        = "glazed"
  description = "rubykaigi-net//tf/glazed"
  vpc_id      = data.aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
