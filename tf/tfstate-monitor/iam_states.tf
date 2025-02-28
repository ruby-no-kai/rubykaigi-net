resource "aws_iam_role" "states" {
  name                 = "StatesTfstateMonitor"
  description          = "rubykaigi-nw tf/tfstate-monitor"
  assume_role_policy   = data.aws_iam_policy_document.states-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "states-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "states.amazonaws.com"
      ]
    }
  }
}


resource "aws_iam_role_policy" "states" {
  role   = aws_iam_role.states.name
  policy = data.aws_iam_policy_document.states.json
}

data "aws_iam_policy_document" "states" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      aws_lambda_function.lambda.arn,
    ]
  }
}
