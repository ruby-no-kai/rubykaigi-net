data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }
}

data "external" "user_data" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./userdata.jsonnet"
  }
}

locals {
  user_data = jsondecode(data.external.user_data.result.json).user_data
}

resource "null_resource" "user_data" {
  triggers = {
    user_data = local.user_data
  }
}

resource "aws_instance" "acme-responder-apne1c" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano"
  subnet_id     = data.aws_subnet.main-public-c.id

  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    aws_security_group.acme-responder.id,
  ]

  user_data = local.user_data

  ipv6_addresses = [
    cidrhost(data.aws_subnet.main-public-c.ipv6_cidr_block, 4294945854) # 0xFFFF_AC3E
  ]

  tags = {
    Name = "acme-responder-apne1c"
  }
  lifecycle {
    ignore_changes       = [ami]
    replace_triggered_by = [null_resource.user_data]
    action_trigger {
      events  = [after_create]
      actions = [action.local_command.provision-apne1c]
    }
  }

  provisioner "remote-exec" {
    inline = ["cloud-init status --wait"]
    connection {
      type         = "ssh"
      user         = "rk"
      host         = self.private_ip
      agent        = true
      bastion_host = "bastion.rubykaigi.net"
    }
  }
}

action "local_command" "provision-apne1c" {
  config {
    command           = "bundle"
    arguments         = ["exec", "hocho", "apply", aws_route53_record.apne1c[data.aws_route53_zone.rubykaigi_net-public.zone_id].fqdn]
    working_directory = "${path.module}/../../itamae"
  }
}

resource "aws_instance" "acme-responder-apne1d" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano"
  subnet_id     = data.aws_subnet.main-public-d.id

  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    aws_security_group.acme-responder.id,
  ]

  user_data = local.user_data

  ipv6_addresses = [
    cidrhost(data.aws_subnet.main-public-d.ipv6_cidr_block, 4294945854) # 0xFFFF_AC3E
  ]

  tags = {
    Name = "acme-responder-apne1d"
  }
  lifecycle {
    ignore_changes       = [ami]
    replace_triggered_by = [null_resource.user_data]
    action_trigger {
      events  = [after_create]
      actions = [action.local_command.provision-apne1d]
    }
  }

  provisioner "remote-exec" {
    inline = ["cloud-init status --wait"]
    connection {
      type         = "ssh"
      user         = "rk"
      host         = self.private_ip
      agent        = true
      bastion_host = "bastion.rubykaigi.net"
    }
  }
}

action "local_command" "provision-apne1d" {
  config {
    command           = "bundle"
    arguments         = ["exec", "hocho", "apply", aws_route53_record.apne1d[data.aws_route53_zone.rubykaigi_net-public.zone_id].fqdn]
    working_directory = "${path.module}/../../itamae"
  }
}
