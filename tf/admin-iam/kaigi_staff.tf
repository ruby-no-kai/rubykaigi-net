resource "aws_iam_role" "KaigiStaff" {
  name                 = "KaigiStaff"
  description          = "rubykaigi-nw:tf/admin-iam aws_iam_role.KaigiStaff"
  assume_role_policy   = data.aws_iam_policy_document.KaigiStaff-trust.json
  max_session_duration = 3600 * 12
}

data "aws_iam_policy_document" "KaigiStaff-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/amc.rubykaigi.net",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "amc.rubykaigi.net:sub"
      values   = ["KaigiStaff:*"]
    }
  }
}


resource "aws_iam_role_policy" "KaigiStaff_StreamingStaff" {
  role   = aws_iam_role.KaigiStaff.name
  policy = data.aws_iam_policy_document.StreamingStaff.json
}

#resource "aws_iam_role_policy" "KaigiStaff" {
#  role   = aws_iam_role.KaigiStaff.name
#  policy = data.aws_iam_policy_document.KaigiStaff.json
#}
#
#data "aws_iam_policy_document" "KaigiStaff" {
#  statement {
#    effect = "Allow"
#    actions = [
#
#    ]
#    resources = ["*"]
#  }
#
#}
