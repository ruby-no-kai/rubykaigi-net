resource "random_id" "client_secret" {
  byte_length = 32
}

data "external" "client_secret_sha384" {
  program = ["ruby", "${path.module}/../sha384.rb"]
  query   = { data = random_id.client_secret.id }
}

locals {
  alb_oidc = {
    authorization_endpoint     = "https://idp.rubykaigi.net/oidc/authorize"
    token_endpoint             = "https://idp.rubykaigi.net/public/oidc/token"
    user_info_endpoint         = "https://idp.rubykaigi.net/public/oidc/userinfo"
    client_id                  = "edfd99bd-b6a4-39ce-d2db-1e7b237295fd"
    client_secret              = random_id.client_secret.id
    issuer                     = "https://idp.rubykaigi.net"
    on_unauthenticated_request = "authenticate"
    scope                      = "openid"
    session_timeout            = 12 * 3600
  }
}

output "oidc_client" {
  value = {
    id          = local.alb_oidc.client_id
    secret_hash = data.external.client_secret_sha384.result.hexdigest
  }
}
