data "aws_iam_role" "FederatedAdmin" {
  name = "FederatedAdmin"
}

data "aws_iam_role" "NocAdmin" {
  name = "NocAdmin"
}

data "aws_iam_role" "OrgzAdmin" {
  name = "OrgzAdmin"
}
