resource "aws_sfn_state_machine" "glazed" {
  name       = "glazed"
  type       = "STANDARD"
  role_arn   = aws_iam_role.StatesGlazed.arn
  definition = jsondecode(aws_lambda_invocation.glazed-state-machine.result).definition
}

output "state_machine_warnings" {
  value = jsondecode(aws_lambda_invocation.glazed-state-machine.result).warnings
}
