resource "aws_sfn_state_machine" "generator" {
  name     = "attendee-gate-generator"
  role_arn = aws_iam_role.states.arn

  definition = jsonencode({
    StartAt = "Generate"
    States = {
      Generate = {
        Type     = "Task"
        Resource = aws_lambda_function.generator.arn
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
