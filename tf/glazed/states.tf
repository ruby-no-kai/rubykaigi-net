locals {
  state_machine_generated = jsondecode(jsondecode(aws_lambda_invocation.glazed-state-machine.result).definition)
  # Batch step of glazed/glazed.jsonnet that needs GitHub
  state_machine_github_state = "backup: github"
  # Points that state at the glazed-github function
  state_machine = merge(local.state_machine_generated, {
    States = merge(local.state_machine_generated.States, {
      Workflows = merge(local.state_machine_generated.States.Workflows, {
        Branches = [
          for branch in local.state_machine_generated.States.Workflows.Branches : merge(branch, {
            States = merge(branch.States, {
              for name, state in branch.States : name => merge(state, {
                Arguments = merge(state.Arguments, {
                  FunctionName = aws_lambda_function.glazed-github.qualified_arn
                })
              }) if name == local.state_machine_github_state
            })
          })
        ]
      })
    })
  })
}

resource "aws_sfn_state_machine" "glazed" {
  name       = "glazed"
  type       = "STANDARD"
  role_arn   = aws_iam_role.StatesGlazed.arn
  definition = jsonencode(local.state_machine)

  lifecycle {
    precondition {
      condition     = anytrue([for branch in local.state_machine_generated.States.Workflows.Branches : contains(keys(branch.States), local.state_machine_github_state)])
      error_message = "The generated state machine has no state named ${local.state_machine_github_state}."
    }
  }
}

output "state_machine_warnings" {
  value = jsondecode(aws_lambda_invocation.glazed-state-machine.result).warnings
}
