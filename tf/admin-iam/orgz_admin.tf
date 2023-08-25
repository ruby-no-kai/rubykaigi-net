resource "aws_iam_role" "OrgzAdmin" {
  name                 = "OrgzAdmin"
  description          = "rubykaigi-nw:tf/admin-iam aws_iam_role.OrgzAdmin"
  assume_role_policy   = data.aws_iam_policy_document.OrgzAdmin-trust.json
  max_session_duration = 3600 * 12
}

data "aws_iam_policy_document" "OrgzAdmin-trust" {
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
      values   = ["${data.aws_caller_identity.current.account_id}:OrgzAdmin:*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "OrgzAdmin_AdministratorAccess" {
  role       = aws_iam_role.OrgzAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
