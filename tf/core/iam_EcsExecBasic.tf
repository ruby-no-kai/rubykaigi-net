resource "aws_iam_role" "EcsExecBasic" {
  name                 = "EcsExecBasic"
  description          = "EcsExecBasic"
  assume_role_policy   = data.aws_iam_policy_document.EcsExecBasic-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
  max_session_duration = 43200
}

data "aws_iam_policy_document" "EcsExecBasic-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy" "EcsExecBasic" {
  role   = aws_iam_role.EcsExecBasic.name
  policy = data.aws_iam_policy_document.EcsExecBasic.json
}

data "aws_iam_policy_document" "EcsExecBasic" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
    ]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.id}:parameter/ecs/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [data.aws_kms_key.usw2_ssm.arn]
  }
}


