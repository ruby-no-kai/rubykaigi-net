resource "aws_secretsmanager_secret" "secret" {
  name = "front-webhook-tweet-to-mastodon/prd/secret"
}
