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
