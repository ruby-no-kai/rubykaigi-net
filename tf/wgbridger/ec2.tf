resource "aws_security_group" "wgbridger" {
  name        = "wgbridger"
  description = "wgbridger"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_security_group_rule" "wgbridger-wg" {
  security_group_id = aws_security_group.wgbridger.id
  type              = "ingress"
  from_port         = 18782
  to_port           = 18782
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_eip" "wgbridger" {
  vpc = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
}

data "aws_key_pair" "default" {
  key_name = "sorah-mulberry-rsa"
}

data "external" "wgbridger" {
  program = ["../jsonnet.rb"]

  query = {
    path = "../cloudconfig.base.libsonnet"
  }
}

resource "aws_instance" "wgbridger" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.micro"
  subnet_id     = data.aws_subnet.main-public-c.id

  vpc_security_group_ids = [data.aws_security_group.default.id, aws_security_group.wgbridger.id]
  iam_instance_profile   = "NwEc2Default"
  key_name               = data.aws_key_pair.default.key_name

  user_data = jsondecode(data.external.wgbridger.result.json).user_data

  tags = {
    Name = "wgbridger"
  }
}

resource "aws_eip_association" "wgbridger" {
  instance_id   = aws_instance.wgbridger.id
  allocation_id = aws_eip.wgbridger.id
}

resource "aws_route53_record" "aaaa-wgbridger_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "wgbridger.rubykaigi.net."
  zone_id  = each.value
  type     = "AAAA"
  ttl      = 60
  records = [
    aws_instance.wgbridger.ipv6_addresses[0],
  ]
}
resource "aws_route53_record" "wgbridger_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "wgbridger.rubykaigi.net."
  zone_id  = each.value
  type     = "A"
  ttl      = 60
  records = [
    aws_eip.wgbridger.public_ip,
  ]
}
resource "aws_route53_record" "wgbridger_apne1_rubykaigi_net" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.id
  name    = "wgbridger.apne1.rubykaigi.net."
  type    = "A"
  ttl     = 60
  records = [
    aws_instance.wgbridger.private_ip,
  ]
}

