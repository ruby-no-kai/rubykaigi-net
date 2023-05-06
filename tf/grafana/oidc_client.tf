resource "random_uuid" "client_id" {
}

resource "random_id" "client_secret" {
  byte_length = 32
}

locals {
  oidc_config = {
    enabled              = true
    name                 = "RubyKaigi-StaffIdP"
    allow_sign_up        = true
    client_id            = random_uuid.client_id.result
    client_secret        = random_id.client_secret.id
    scopes               = "openid"
    email_attribute_path = "email"
    login_attribute_path = "sub"
    name_attribute_path  = "name"
    auth_url             = "https://idp.rubykaigi.net/oidc/authorize"
    token_url            = "https://idp.rubykaigi.net/public/oidc/token"
    api_url              = "https://idp.rubykaigi.net/public/oidc/userinfo"

    role_attribute_path        = "contains(roles[*], 'admin') && 'GrafanaAdmin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'"
    allow_assign_grafana_admin = true
  }
}

output "oidc_client" {
  value = {
    id     = local.oidc_config.client_id
    secret = local.oidc_config.client_secret
  }
}
