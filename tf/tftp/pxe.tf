# /ro/compute/grubx64.efi
# /ro/compute/noble/vmlinuz
# /ro/compute/noble/initrd
# /tftpboot/grub/grub.cfg

resource "aws_s3_object" "ipxe" {
  for_each = toset([
    "default.ipxe",
    "consts.ipxe",
    "menu.ipxe",
  ])
  bucket       = aws_s3_bucket.tftp.id
  key          = "ro/compute/${each.key}"
  content      = file("${path.module}/${each.key}")
  content_type = "text/plain"
}

#resource "aws_s3_object" "grub-cfg" {
#  bucket  = aws_s3_bucket.tftp.id
#  key     = "tftpboot/grub/grub.cfg"
#  content = <<-EOF
#    set timeout=2
#    loadfont unicode
#    set menu_color_normal=white/black
#    set menu_color_highlight=black/light-gray
#    if [ -s "$${prefix}/system/$${net_default_mac}" ]; then
#      source "$${prefix}/system/$${net_default_mac}"
#      echo "Machine specific grub config file $${prefix}/system/$${net_default_mac} loaded"
#    fi
#
#    menuentry "Auto install Ubuntu Server (noble)" {
#      set gfxpayload=keep
#      linux   /ro/compute/noble/vmlinuz autoinstall ip=dhcp url=https://tftp.rubykaigi.net/ro/compute/noble/ubuntu-24.04.2-live-server-amd64.iso ds=nocloud-net\;s=https://tftp.rubykaigi.net/ro/compute/noble/autoinstall/default/ ---
#      initrd  /ro/compute/noble/initrd
#    }
#  EOF
#
#  content_type = "text/plain"
#}

data "external" "default-cloud-config-user" {
  program = ["../jsonnet.rb"]

  query = {
    path = "${path.module}/default.jsonnet"
  }
}
resource "aws_s3_object" "default-cloud-config-user" {
  bucket       = aws_s3_bucket.tftp.id
  key          = "ro/compute/noble/autoinstall/default/user-data"
  content      = jsondecode(data.external.default-cloud-config-user.result.json).user_data
  content_type = "text/cloud-config"
}
resource "aws_s3_object" "default-cloud-config-meta" {
  bucket       = aws_s3_bucket.tftp.id
  key          = "ro/compute/noble/autoinstall/default/meta-data"
  content      = ""
  content_type = "text/plain"
}
