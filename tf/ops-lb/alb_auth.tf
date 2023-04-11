resource "random_uuid" "client_id" {
}

resource "random_id" "client_secret" {
  byte_length = 32
}

locals {
  alb_oidc = {
    authorization_endpoint     = "https://idp.rubykaigi.net/oidc/authorize"
    token_endpoint             = "https://idp.rubykaigi.net/public/oidc/token"
    user_info_endpoint         = "https://idp.rubykaigi.net/public/oidc/userinfo"
    client_id                  = random_uuid.client_id.result
    client_secret              = random_id.client_secret.id
    issuer                     = "https://idp.rubykaigi.net"
    on_unauthenticated_request = "authenticate"
    scope                      = "openid"
    session_timeout            = 3600
  }
}

output "oidc_client" {
  value = {
    id     = local.alb_oidc.client_id
    secret = local.alb_oidc.client_secret
  }
}
