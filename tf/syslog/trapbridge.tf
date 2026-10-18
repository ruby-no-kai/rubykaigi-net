resource "aws_cloudwatch_log_group" "trapbridge" {
  name              = "/aws/events/trapbridge"
  retention_in_days = 14
}

data "aws_iam_policy_document" "trapbridge-logs" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.trapbridge.arn}:*"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com", "delivery.logs.amazonaws.com"]
    }
  }
}

# EventBridge does not use the caller's IAM role for CloudWatch Logs targets.
resource "aws_cloudwatch_log_resource_policy" "trapbridge" {
  policy_name     = "trapbridge-events"
  policy_document = data.aws_iam_policy_document.trapbridge-logs.json
}

resource "aws_cloudwatch_event_rule" "trapbridge" {
  name        = "trapbridge"
  description = "rubykaigi-net//tf/syslog"
  event_pattern = jsonencode({
    source = ["trapbridge.0w0.co"]
  })
}

resource "aws_cloudwatch_event_target" "trapbridge-logs" {
  rule = aws_cloudwatch_event_rule.trapbridge.name
  arn  = aws_cloudwatch_log_group.trapbridge.arn
}
