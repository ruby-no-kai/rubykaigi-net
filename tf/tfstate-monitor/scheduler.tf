# EventBridge Scheduler resource to trigger Step Functions

resource "aws_scheduler_schedule" "schedule" {
  name = "tfstate-monitor"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 360
  }
  schedule_expression = "cron(20 0 * * ? *)"

  target {
    arn      = aws_sfn_state_machine.tfstate-monitor.arn
    role_arn = aws_iam_role.events.arn
    input = jsonencode({
      no_cache = true
    })
  }
}
