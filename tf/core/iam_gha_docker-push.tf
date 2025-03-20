resource "aws_iam_role" "GhaDockerPush" {
  name                 = "GhaDockerPush"
  assume_role_policy   = data.aws_iam_policy_document.GhaDockerPush-trust.json
  max_session_duration = 3600 * 4
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "GhaDockerPush-trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github-actions.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ruby-no-kai/rubykaigi-net:ref:refs/heads/master",
        "repo:ruby-no-kai/rubykaigi-net:ref:refs/heads/test",
        "repo:ruby-no-kai/rubykaigi-net-apps:ref:refs/heads/main",
        "repo:ruby-no-kai/rubykaigi-net-apps:ref:refs/heads/test",
        "repo:ruby-no-kai/rko-router:ref:refs/heads/master",
        "repo:ruby-no-kai/rko-router:ref:refs/heads/test",
        "repo:ruby-no-kai/takeout-app:ref:refs/heads/master",
        "repo:ruby-no-kai/takeout-app:ref:refs/heads/test",
        "repo:ruby-no-kai/sponsor-app:ref:refs/heads/master",
        "repo:ruby-no-kai/sponsor-app:ref:refs/heads/test",
      ]
    }
  }

}

resource "aws_iam_role_policy" "GhaDockerPush" {
  role   = aws_iam_role.GhaDockerPush.id
  name   = "GhaDockerPush"
  policy = data.aws_iam_policy_document.GhaDockerPush.json
}

data "aws_iam_policy_document" "GhaDockerPush" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecr-public:GetAuthorizationToken",
      "ecr:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr-public:BatchCheckLayerAvailability",
      "ecr:GetAuthorizationToken",
      "ecr-public:CompleteLayerUpload",
      "ecr-public:InitiateLayerUpload",
      "ecr-public:PutImage",
      "ecr-public:UploadLayerPart",

      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage",

      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/kea",
      "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/fluentd",
      "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/unbound",
      "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/dnscollector",
      "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/dnsdist",
      "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/rko-router",
      "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/radiusd",
      "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/freeradius-exporter",
      "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/s3tftpd-healthz",

      "arn:aws:ecr:us-west-2:${data.aws_caller_identity.current.account_id}:repository/takeout-app",
      "arn:aws:ecr:us-west-2:${data.aws_caller_identity.current.account_id}:repository/sponsor-app",
      "arn:aws:ecr:us-west-2:${data.aws_caller_identity.current.account_id}:repository/slack-thread-expander",
      "arn:aws:ecr:us-west-2:${data.aws_caller_identity.current.account_id}:repository/attendee-gate",
    ]
  }
}
