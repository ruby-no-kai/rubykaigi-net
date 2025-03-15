resource "aws_iam_role" "events" {
  name               = "EventsAttendeeGate"
  description        = "rubykaigi-net//tf/attendee-gate"
  assume_role_policy = data.aws_iam_policy_document.events-trust.json
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
      aws_sfn_state_machine.generator.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      aws_lambda_function.metrics.arn,
    ]
  }
}
