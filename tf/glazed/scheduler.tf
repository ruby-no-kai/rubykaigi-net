resource "aws_scheduler_schedule" "glazed-daily" {
  name = "glazed-daily"

  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression          = "cron(0 4 * * ? *)"
  schedule_expression_timezone = "Asia/Tokyo"

  target {
    arn      = aws_sfn_state_machine.glazed.arn
    role_arn = aws_iam_role.EventsGlazed.arn
    input = jsonencode({
      signals = [
        {
          all_nodes = true
          workflows = ["backup"]
          source    = "daily"
          immediate = true
        },
      ]
    })
  }
}

# Starts a waiter for due retries and intervals after the last one ended
resource "aws_scheduler_schedule" "glazed-tick" {
  name = "glazed-tick"

  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = "rate(1 hour)"

  target {
    arn      = aws_sfn_state_machine.glazed.arn
    role_arn = aws_iam_role.EventsGlazed.arn
    input    = jsonencode({})
  }
}
