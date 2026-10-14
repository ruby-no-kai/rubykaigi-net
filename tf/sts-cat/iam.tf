data "aws_iam_policy" "NocAdminBase" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "LambdaStsCat" {
  name                 = "LambdaStsCat"
  description          = "rubykaigi-net//tf/sts-cat"
  assume_role_policy   = data.aws_iam_policy_document.LambdaStsCat-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "LambdaStsCat-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "LambdaStsCat" {
  role   = aws_iam_role.LambdaStsCat.name
  name   = "LambdaStsCat"
  policy = data.aws_iam_policy_document.LambdaStsCat.json
}

data "aws_iam_policy_document" "LambdaStsCat" {
  statement {
    effect    = "Allow"
    actions   = ["kms:Sign"]
    resources = [aws_kms_external_key.sts-cat.arn]
  }
}

resource "aws_iam_role_policy_attachment" "LambdaStsCat-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.LambdaStsCat.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
