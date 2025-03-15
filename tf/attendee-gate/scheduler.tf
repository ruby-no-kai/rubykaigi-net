resource "aws_scheduler_schedule" "schedule" {
  name = "attendee-gate-generator"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 60
  }
  schedule_expression = "rate(6 hour)"

  target {
    arn      = aws_sfn_state_machine.generator.arn
    role_arn = aws_iam_role.events.arn
    input = jsonencode({
      bucket     = local.environment.S3_BUCKET,
      key        = local.environment.S3_KEY,
      event_slug = local.event_slug
    })
  }
}

resource "aws_scheduler_schedule" "metrics" {
  for_each = toset([
    "rubykaigi/2024",
    "rubykaigi/2025",
    "rubykaigi/2025-party",
  ])
  name = "attendee-gate-metrics-${replace(each.value, "/", "-")}"

  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = "rate(5 minutes)"

  target {
    arn      = aws_lambda_function.metrics.arn
    role_arn = aws_iam_role.events.arn
    input = jsonencode({
      bucket     = local.environment.S3_BUCKET,
      key        = "prd/prometheus/${each.value}",
      event_slug = each.value
    })
  }
}
