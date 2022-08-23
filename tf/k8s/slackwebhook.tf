data "aws_ssm_parameter" "slack-webhook-url" {
  name = "/misc/network-slack-webhook-url"
}
