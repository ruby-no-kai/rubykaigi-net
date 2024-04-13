data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
}

resource "terraform_data" "acme_userdata" {
  input = file("${path.module}/userdata.yml")
}

resource "aws_instance" "acme-responder" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano"
  subnet_id     = data.aws_subnet.main-public-c.id

  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    aws_security_group.acme-responder.id,
  ]

  user_data = terraform_data.acme_userdata.output

  ipv6_addresses = [
    "2406:da14:dfe:c0c0::30fe",
  ]

  tags = {
    Name = "acme-responder"
  }
  lifecycle {
    ignore_changes       = [ami]
    replace_triggered_by = [terraform_data.acme_userdata]
  }
}
