data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.main.id
}
data "aws_security_group" "bastion" {
  name   = "bastion"
  vpc_id = data.aws_vpc.main.id
}
data "aws_iam_instance_profile" "bastion" {
  name = "NwBastion"
}
data "aws_key_pair" "default" {
  key_name = "sorah-mulberry-rsa"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }
}

resource "aws_eip" "bastion" {
  domain = "vpc"
}

data "external" "bastion" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./bastion.jsonnet"
  }
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.micro"
  subnet_id     = data.aws_subnet.main-public-c.id

  vpc_security_group_ids = [data.aws_security_group.default.id, data.aws_security_group.bastion.id]
  iam_instance_profile   = data.aws_iam_instance_profile.bastion.name
  #key_name               = data.aws_key_pair.default.key_name

  user_data = jsondecode(data.external.bastion.result.json).user_data

  tags = {
    Name = "bastion"
  }
  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}

resource "aws_route53_record" "aaaa-bastion_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "bastion.rubykaigi.net."
  zone_id  = each.value
  type     = "AAAA"
  ttl      = 60
  records = [
    aws_instance.bastion.ipv6_addresses[0],
  ]
}
resource "aws_route53_record" "bastion_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "bastion.rubykaigi.net."
  zone_id  = each.value
  type     = "A"
  ttl      = 60
  records = [
    aws_eip.bastion.public_ip,
  ]
}
