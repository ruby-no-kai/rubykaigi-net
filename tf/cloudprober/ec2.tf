locals {
  cloudprober_port = 9313
}

data "aws_iam_instance_profile" "default" {
  name = "NwEc2Default"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
}

resource "aws_instance" "cloudprober-az-c" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.micro"
  subnet_id     = data.aws_subnet.main-public-c.id

  associate_public_ip_address = true

  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    aws_security_group.cloudprober.id,
  ]
  iam_instance_profile = data.aws_iam_instance_profile.default.name

  user_data = "#cloud-config\n${data.external.cloud-config.result.json}"

  tags = {
    Name = "cloudprober-az-c"
  }

  lifecycle {
    ignore_changes        = [ami]
    replace_triggered_by  = [terraform_data.replacement]
    create_before_destroy = true
  }
}

data "external" "cloud-config" {
  program = ["${path.module}/../jsonnet.rb"]

  query = {
    path = "${path.module}/cloudconfig.jsonnet"
  }
}

resource "terraform_data" "replacement" {
  input = {
    user_data_hash = sha1(data.external.cloud-config.result.json)
  }
}
