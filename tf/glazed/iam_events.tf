resource "aws_iam_role" "EventsGlazed" {
  name                 = "EventsGlazed"
  description          = "rubykaigi-net//tf/glazed"
  assume_role_policy   = data.aws_iam_policy_document.EventsGlazed-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "EventsGlazed-trust" {
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

resource "aws_iam_role_policy" "EventsGlazed" {
  role   = aws_iam_role.EventsGlazed.name
  policy = data.aws_iam_policy_document.EventsGlazed.json
}

data "aws_iam_policy_document" "EventsGlazed" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution",
    ]
    resources = [
      aws_sfn_state_machine.glazed.arn,
      aws_sfn_state_machine.glazed-trap.arn,
    ]
  }
}
