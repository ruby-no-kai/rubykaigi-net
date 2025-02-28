# Trigger Step Functions via EventBridge S3 event

data "aws_s3_bucket" "rk-infra" {
  bucket = "rk-infra"
}

resource "aws_cloudwatch_event_rule" "tfstate" {
  name = "tfstate-monitor"
  event_pattern = jsonencode({
    source      = ["aws.s3"],
    detail-type = ["Object Created"],
    detail = {
      bucket = {
        name = ["${data.aws_s3_bucket.rk-infra.bucket}"],
      }
      object = {
        key = [{ wildcard = "terraform/*.tfstate" }],
      }
    },
  })
}

resource "aws_cloudwatch_event_target" "tfstate" {
  rule      = aws_cloudwatch_event_rule.tfstate.name
  target_id = "tfstate-monitor"
  arn       = aws_sfn_state_machine.tfstate-monitor.arn
  role_arn  = aws_iam_role.events.arn
}
