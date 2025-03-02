data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
}

data "external" "acme_userdata" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./userdata.jsonnet"
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

  user_data = jsondecode(data.external.bastion.result.json).user_data

  ipv6_addresses = [
    "2406:da14:dfe:c0c0::30fe",
  ]

  tags = {
    Name = "acme-responder"
  }
  lifecycle {
    ignore_changes       = [ami]
    replace_triggered_by = [user_data]
  }
}
