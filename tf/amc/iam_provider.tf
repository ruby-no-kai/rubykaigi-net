resource "aws_iam_openid_connect_provider" "amc" {
  url = "https://amc.rubykaigi.net"

  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [data.external.amc-ca-thumbprint.result.thumbprint]
}

data "external" "amc-ca-thumbprint" {
  program    = ["${path.module}/ca_thumbprint.sh", "amc.rubykaigi.net"]
  depends_on = [aws_route53_record.amc_rubykaigi_net]
}
