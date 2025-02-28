resource "aws_sfn_state_machine" "tfstate-monitor" {
  name     = "tfstate-monitor"
  role_arn = aws_iam_role.states.arn

  definition = jsonencode({
    StartAt = "Monitor"
    States = {
      Monitor = {
        Type     = "Task"
        Resource = aws_lambda_function.lambda.arn
        End      = true
        Retry = [
          {
            ErrorEquals = [
              "States.TaskFailed"
            ]
            BackoffRate     = 2
            IntervalSeconds = 3
            MaxAttempts     = 4
            JitterStrategy  = "FULL"
          },
        ]
      }
    }
  })
}
