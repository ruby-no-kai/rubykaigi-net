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

resource "aws_s3_object" "resolute-cloud-config-user" {
  bucket       = aws_s3_bucket.tftp.id
  key          = "ro/compute/resolute/autoinstall/default/user-data"
  content      = jsondecode(data.external.default-cloud-config-user.result.json).user_data
  content_type = "text/cloud-config"
}
resource "aws_s3_object" "resolute-cloud-config-meta" {
  bucket       = aws_s3_bucket.tftp.id
  key          = "ro/compute/resolute/autoinstall/default/meta-data"
  content      = ""
  content_type = "text/plain"
}
