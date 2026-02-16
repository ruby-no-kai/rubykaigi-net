data "aws_iam_policy" "NocAdminBase" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "lambda" {
  name                 = "LambdaSkopeoCopy"
  description          = "rubykaigi-net//tf/skopeo-copy"
  assume_role_policy   = data.aws_iam_policy_document.lambda-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "lambda-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda" {
  role   = aws_iam_role.lambda.name
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role" "lambda-unrestricted" {
  name               = "LambdaSkopeoCopyUnrestricted"
  description        = "rubykaigi-net//tf/skopeo-copy (unrestricted, no permissions boundary)"
  assume_role_policy = data.aws_iam_policy_document.lambda-trust.json
}

resource "aws_iam_role_policy_attachment" "lambda-unrestricted-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.lambda-unrestricted.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda-unrestricted" {
  role   = aws_iam_role.lambda-unrestricted.name
  policy = data.aws_iam_policy_document.lambda.json
}

data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr-public:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/SkopeoCopy"
      values   = ["1"]
    }
  }
}
