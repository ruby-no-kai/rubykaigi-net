resource "aws_instance" "bastion-onpremises" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.micro"
  subnet_id     = data.aws_subnet.main-onpremises-c.id

  vpc_security_group_ids = [data.aws_security_group.default.id, data.aws_security_group.bastion.id]
  iam_instance_profile   = data.aws_iam_instance_profile.bastion.name
  #key_name               = data.aws_key_pair.default.key_name

  user_data = jsondecode(data.external.bastion.result.json).user_data

  tags = {
    Name = "bastion-onpremises"
  }
  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_route53_record" "aaaa-bastion-onpremises_rubykaigi_net" {
  name    = "bastion-onpremises.rubykaigi.net."
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id
  type    = "A"
  ttl     = 60
  records = [
    aws_instance.bastion-onpremises.private_ip,
  ]
}
