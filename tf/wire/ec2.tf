data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    #values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-arm64-server-*"]
    values = ["ubuntu/images-testing/hvm-ssd-gp3/ubuntu-resolute-daily-arm64-server-*"]
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

resource "aws_instance" "wire" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.small"
  subnet_id     = data.aws_subnet.main-public-c.id

  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    aws_security_group.wire.id,
  ]

  user_data = local.user_data

  associate_public_ip_address = true
  ipv6_addresses = [
    cidrhost(data.aws_subnet.main-public-c.ipv6_cidr_block, parseint("88889999", 16))
  ]

  tags = {
    Name = "wire"
  }
  lifecycle {
    ignore_changes       = [ami]
    replace_triggered_by = [null_resource.user_data]
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

action "local_command" "provision" {
  config {
    command           = "bundle"
    arguments         = ["exec", "hocho", "apply", aws_route53_record.wire[data.aws_route53_zone.rubykaigi_net-public.zone_id].fqdn]
    working_directory = "${path.module}/../../itamae"
  }
}

resource "aws_network_interface" "wire_overlay" {
  subnet_id = data.aws_subnet.main-public-c.id

  security_groups = [
    data.aws_security_group.default.id,
    aws_security_group.wire.id,
  ]

  ipv6_address_count = 1

  tags = {
    Name = "wire-overlay"
  }
}

resource "aws_network_interface_attachment" "wire_overlay" {
  instance_id          = aws_instance.wire.id
  network_interface_id = aws_network_interface.wire_overlay.id
  device_index         = 1

  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.local_command.provision]
    }
  }
}

resource "aws_eip" "wire_overlay" {
  domain = "vpc"

  tags = {
    Name = "wire-overlay"
  }
}

resource "aws_eip_association" "wire_overlay" {
  allocation_id        = aws_eip.wire_overlay.id
  network_interface_id = aws_network_interface.wire_overlay.id
}
