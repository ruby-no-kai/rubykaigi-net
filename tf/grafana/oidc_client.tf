locals {
  oidc_config = {
    enabled              = true
    name                 = "RubyKaigi Staff IdP"
    allow_sign_up        = true
    client_id            = "$__file{/var/run/secrets/oidc-client/client_id}"
    client_secret        = "$__file{/var/run/secrets/oidc-client/client_secret}"
    scopes               = "openid"
    email_attribute_path = "email"
    login_attribute_path = "sub"
    name_attribute_path  = "name"
    auth_url             = "https://idp.rubykaigi.net/oidc/authorize"
    token_url            = "https://idp.rubykaigi.net/public/oidc/token"
    api_url              = "https://idp.rubykaigi.net/public/oidc/userinfo"
    use_pkce             = true

    role_attribute_path        = "contains(roles[*], 'admin') && 'GrafanaAdmin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'"
    allow_assign_grafana_admin = true
  }
}

resource "random_id" "client_secret" {
  byte_length = 32
}
data "external" "client_secret_sha384" {
  program = ["ruby", "${path.module}/../sha384.rb"]
  query   = { data = random_id.client_secret.id }
}
output "oidc_client" {
  value = {
    id          = "bc0d7e96-8bd9-3fea-357c-aea827e4353b"
    secret_hash = data.external.client_secret_sha384.result.hexdigest
  }
}

resource "kubernetes_secret" "oidc-client" {
  metadata {
    name = "grafana-oidc-client"
  }

  data = {
    client_id     = "bc0d7e96-8bd9-3fea-357c-aea827e4353b"
    client_secret = random_id.client_secret.id
  }
}
