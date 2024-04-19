locals {
  v6gws = tomap({ for subnet in data.aws_subnet.main-private :
    "v6gw-${substr(subnet.availability_zone, -1, -1)}001" => {
      az  = subnet.availability_zone,
      seq = 1
    }
  })
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }
}

data "external" "v6gw-cloudconfig" {
  for_each = local.v6gws

  program = ["../jsonnet.rb"]

  query = {
    path = "./cloudconfig.jsonnet"
  }
}

data "template_cloudinit_config" "v6gw" {
  for_each = local.v6gws

  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = data.external.v6gw-cloudconfig[each.key].result.json
  }
}

resource "terraform_data" "v6gw-userdata" {
  for_each = local.v6gws

  input = data.template_cloudinit_config.v6gw[each.key].rendered
}

resource "aws_instance" "v6gw" {
  for_each = local.v6gws

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano"
  subnet_id     = data.aws_subnet.main-private[each.value.az].id

  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    aws_security_group.v6gw.id,
  ]

  user_data = terraform_data.v6gw-userdata[each.key].output

  key_name = "hanazuki-1p-main" # TODO: remove

  ipv6_addresses = [
    replace(data.aws_subnet.main-private[each.value.az].ipv6_cidr_block, "::/64", format("::66:%x", each.value.seq)),
  ]

  tags = {
    Name = each.key
  }

  lifecycle {
    ignore_changes       = [ami]
    replace_triggered_by = [terraform_data.v6gw-userdata[each.key]]
  }
}

resource "terraform_data" "nodedata" {
  for_each = local.v6gws

  input = jsonencode({
    overlay_prefix = "2001:df0:8500:ca60::/64"
    ipv6token      = format("::66:%x", each.value.seq),
  })
}

resource "null_resource" "v6gw-provision" {
  for_each = local.v6gws

  connection {
    host = aws_instance.v6gw[each.key].private_ip
    user = "rk"

    bastion_host = "bastion.rubykaigi.net"
    bastion_port = 9922
    bastion_user = "rk"
  }

  provisioner "file" {
    destination = "/tmp/itamae-recipes.zip"
    source      = data.archive_file.recipes.output_path
  }

  provisioner "file" {
    destination = "/tmp/itamae-node.json"
    content     = terraform_data.nodedata[each.key].output
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOF
        #!/bin/bash
        set -ex
        cloud-init status --wait >/dev/null
        workdir=$(mktemp -d)
        pushd "$workdir"
        unzip /tmp/itamae-recipes.zip
        sudo mitamae local -j /tmp/itamae-node.json ./default.rb
        popd
        rm -rf "$workdir"
      EOF
    ]
  }

  triggers = {
    instance = aws_instance.v6gw[each.key].private_ip
    recipes  = filesha1(data.archive_file.recipes.output_path)
    node     = terraform_data.nodedata[each.key].output
  }
}

data "archive_file" "recipes" {
  type        = "zip"
  output_path = "./itamae-recipes.zip"
  source_dir  = "./itamae"
}

output "private_ips" {
  value = [for i in aws_instance.v6gw : i.private_ip]
}
