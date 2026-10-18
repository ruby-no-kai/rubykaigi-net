resource "aws_iam_role" "StatesGlazed" {
  name                 = "StatesGlazed"
  description          = "rubykaigi-net//tf/glazed"
  assume_role_policy   = data.aws_iam_policy_document.StatesGlazed-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "StatesGlazed-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "states.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy" "StatesGlazed" {
  role   = aws_iam_role.StatesGlazed.name
  policy = data.aws_iam_policy_document.StatesGlazed.json
}

data "aws_iam_policy_document" "StatesGlazed" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      "${aws_lambda_function.glazed.arn}:*",
      "${aws_lambda_function.glazed-github.arn}:*",
    ]
  }
}

resource "aws_iam_role" "StatesGlazedTrap" {
  name                 = "StatesGlazedTrap"
  description          = "rubykaigi-net//tf/glazed"
  assume_role_policy   = data.aws_iam_policy_document.StatesGlazed-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

resource "aws_iam_role_policy" "StatesGlazedTrap" {
  role   = aws_iam_role.StatesGlazedTrap.name
  policy = data.aws_iam_policy_document.StatesGlazedTrap.json
}

data "aws_iam_policy_document" "StatesGlazedTrap" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution",
    ]
    resources = [
      aws_sfn_state_machine.glazed.arn,
    ]
  }
}
