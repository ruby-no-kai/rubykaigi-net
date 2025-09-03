data "aws_s3_bucket" "dot-net" {
  bucket = "rubykaigi-dot-net"
}

resource "null_resource" "s3-authorized-keys" {
  triggers = {
    hash1 = sha512(file("${path.module}/ssh_keys.rb"))
    hash2 = sha512(file("${path.module}/../../data/ssh_import_ids.json"))
  }
  provisioner "local-exec" {
    command = "ruby ssh_keys.rb"
    environment = {
      SSH_IMPORT_ID_FILE = "${path.module}/../../data/ssh_import_ids.json"
      S3_BUCKET          = data.aws_s3_bucket.dot-net.bucket
      S3_KEY             = "authorized_keys"
      AWS_REGION         = data.aws_region.current.name
    }
  }
}


