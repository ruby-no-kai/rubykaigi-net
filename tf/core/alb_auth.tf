locals {
  alb_oidc = {
    authorization_endpoint     = "https://idp.rubykaigi.net/auth"
    token_endpoint             = "https://idp-internal.rubykaigi.net/token"
    user_info_endpoint         = "https://idp-internal.rubykaigi.net/userinfo"
    client_id                  = "5VM7b7zXTEcQA5zcW2wmY0PM7RK2W6yT5M6xglFj8SI"
    client_secret              = "rQHgwpnOwsUTpvp6QDttq2KNs53HMbtPp5k4Go307Ds"
    issuer                     = "https://idp.rubykaigi.net"
    on_unauthenticated_request = "authenticate"
    session_timeout            = 12 * 3600
  }
}
