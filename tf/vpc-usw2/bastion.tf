resource "aws_security_group" "bastion" {
  vpc_id      = aws_vpc.main.id
  name        = "bastion"
  description = "bastion"
}

resource "aws_security_group_rule" "bastion_ssh9922" {
  security_group_id = aws_security_group.bastion.id
  type              = "ingress"
  from_port         = 9922
  to_port           = 9922
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_eip" "bastion" {
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

data "aws_iam_instance_profile" "bastion" {
  name = "NwBastion"
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano"
  subnet_id     = aws_subnet.c_public.id

  vpc_security_group_ids = [aws_security_group.default.id, aws_security_group.bastion.id]
  iam_instance_profile   = data.aws_iam_instance_profile.bastion.name
  #key_name               = data.aws_key_pair.default.key_name

  user_data = file("./bastion.yml")

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

resource "aws_route53_record" "aaaa-bastion-usw2_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "bastion-usw2.rubykaigi.net."
  zone_id  = each.value
  type     = "AAAA"
  ttl      = 60
  records = [
    aws_instance.bastion.ipv6_addresses[0],
  ]
}
resource "aws_route53_record" "bastion-usw2_rubykaigi_net" {
  for_each = local.rubykaigi_net_zones
  name     = "bastion-usw2.rubykaigi.net."
  zone_id  = each.value
  type     = "A"
  ttl      = 60
  records = [
    aws_eip.bastion.public_ip,
  ]
}

