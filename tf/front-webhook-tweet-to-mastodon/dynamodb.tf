resource "aws_dynamodb_table" "table" {
  name         = "front-webhook-tweet-to-mastodon_main_prd"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  tags = {
    Environment = "production"
  }
}
