resource "aws_iam_role" "events" {
  name                 = "EventsTfstateMonitor"
  description          = "rubykaigi-nw tf/tfstate-monitor"
  assume_role_policy   = data.aws_iam_policy_document.events-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "events-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "scheduler.amazonaws.com",
      ]
    }
  }
}


resource "aws_iam_role_policy" "events" {
  role   = aws_iam_role.events.name
  policy = data.aws_iam_policy_document.events.json
}

data "aws_iam_policy_document" "events" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution",
    ]
    resources = [
      aws_sfn_state_machine.tfstate-monitor.arn,
    ]
  }
}
