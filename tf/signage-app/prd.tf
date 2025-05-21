locals {
  captioner_enabled = false
}
module "prd" {
  source = "github.com/ruby-no-kai/signage-app//tf"
  #source = "/home/sorah/git/github.com/ruby-no-kai/signage-app/tf"

  name_prefix     = "signage-prd"
  iam_role_prefix = "SignagePrd"

  app_domain     = "signage.rubykaigi.org"
  cognito_domain = "rk-signage-prd"

  certificate_arn = data.aws_acm_certificate.use1-wild-rk-o.arn

  # himari
  oidc_issuer        = "https://idp.rubykaigi.net"
  oidc_client_id     = "13756142-32e6-4379-aad4-52f3501485bc"
  oidc_client_secret = sensitive(random_id.prd_client_secret.id)

  cloudfront_log_bucket = "rk-aws-logs.s3.amazonaws.com"
  cloudfront_log_prefix = "cf/signage.rubykaigi.org/"

  github_actions_subs = ["repo:ruby-no-kai/signage-app:environment:prd"]

  captioner_enabled = local.captioner_enabled
  captioner_params = {
    vpc_id                            = data.aws_vpc.main.id
    ec2_security_group_ids            = [data.aws_security_group.default.id, aws_security_group.captioner.id]
    medialive_input_security_group_id = aws_medialive_input_security_group.anywhere.id
    ec2_subnet_id                     = data.aws_subnet.main-public-c.id
    medialive_subnet_id_1             = data.aws_subnet.main-public-c.id
    medialive_subnet_id_2             = data.aws_subnet.main-public-d.id
    medialive_security_group_ids      = [data.aws_security_group.default.id, aws_security_group.medialive.id]
    medialive_s3_bucket               = aws_s3_bucket.live.bucket
    medialive_s3_prefix               = "rk25/"
    ssh_import_ids                    = jsondecode(file("${path.module}/../../data/ssh_import_ids.json"))
  }
  captioner_channels = {
    a = {
      stream_key = random_pet.prd-stream-key.id
      udp_port   = 30001
    }
    b = {
      stream_key = random_pet.prd-stream-key.id
      udp_port   = 30002
    }
    c = {
      stream_key = random_pet.prd-stream-key.id
      udp_port   = 30003
    }
  }

  callback_urls = toset([])

  ssm_parameter_path_prefix = "/signage/prd/"
}

resource "aws_route53_record" "prd" {
  for_each = merge([for zone in local.rubykaigi_net_zones : { "${zone}-A" = [zone, "A"], "${zone}-AAAA" = [zone, "AAAA"] }]...)
  name     = "signage-prd-cf.rubykaigi.net."
  zone_id  = each.value[0]
  type     = each.value[1]
  alias {
    name    = module.prd.cloudfront_distribution_domain_name
    zone_id = "Z2FDTNDATAQYW2" # CloudFront https://docs.aws.amazon.com/Route53/latest/APIReference/API_AliasTarget.html
    //
    evaluate_target_health = true
  }
}

resource "random_pet" "prd-stream-key" {
  keepers = {
    doggo = "rk25"
  }
}

resource "random_id" "prd_client_secret" {
  byte_length = 64
}
#output "dev_oidc_client_secret" {
#  value = random_id.dev_client_secret.id
#}

resource "aws_route53_record" "prd-captioner-public" {
  count   = local.captioner_enabled ? 1 : 0
  zone_id = data.aws_route53_zone.rubykaigi-net_public.zone_id
  name    = "captioner.apne1.rubykaigi.net."
  type    = "A"
  ttl     = 60
  records = [
    module.prd.captioner_ip_address,
  ]
}
resource "aws_route53_record" "prd-captioner-private" {
  count   = local.captioner_enabled ? 1 : 0
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id
  name    = "captioner.apne1.rubykaigi.net."
  type    = "A"
  ttl     = 60
  records = [
    module.prd.captioner_ip_address,
  ]
}


output "prd" {
  value     = module.prd
  sensitive = true
}
output "prd_oidc_client_secret" {
  value     = random_id.prd_client_secret.id
  sensitive = true
}

