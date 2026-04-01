data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }
}

data "external" "acme_userdata" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./userdata.jsonnet"
  }
}

locals {
  user_data = jsondecode(data.external.acme_userdata.result.json).user_data
}

resource "null_resource" "user-data" {
  triggers = {
    user_data = local.user_data
  }
}

resource "aws_instance" "acme-responder" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano"
  subnet_id     = data.aws_subnet.main-public-c.id

  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    aws_security_group.acme-responder.id,
  ]

  user_data = local.user_data

  ipv6_addresses = [
    "2406:da14:dfe:c0c0::30fe",
  ]

  tags = {
    Name = "acme-responder"
  }
  lifecycle {
    ignore_changes       = [ami]
    replace_triggered_by = [null_resource.user-data]
  }
}
