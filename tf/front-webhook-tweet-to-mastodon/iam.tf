resource "aws_iam_role" "function" {
  name               = "LambdaFrontWebhookTweetToMastodon"
  description        = "rubykaigi-nw tf/front-webhook-tweet-to-mastodon aws_iam_role.function"
  assume_role_policy = data.aws_iam_policy_document.function-trust.json
}

data "aws_iam_policy_document" "function-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "function-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.function.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "function" {
  role   = aws_iam_role.function.name
  policy = data.aws_iam_policy_document.function.json
}

data "aws_iam_policy_document" "function" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
    resources = [
      aws_sqs_queue.inbox.arn,
      aws_sqs_queue.inbox-dlq.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
    ]
    resources = [aws_dynamodb_table.table.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [aws_secretsmanager_secret.secret.arn]
  }
}
