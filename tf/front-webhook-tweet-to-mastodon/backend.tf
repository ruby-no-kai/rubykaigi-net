terraform {
  backend "s3" {
    bucket         = "rk-infra"
    region         = "ap-northeast-1"
    key            = "terraform/front-webhook-tweet-to-mastodon.tfstate"
    dynamodb_table = "rk-terraform"
  }
}
