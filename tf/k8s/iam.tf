module "iam" {
  source = "github.com/cookpad/terraform-aws-eks//modules/iam?ref=79d6a080cec911103cceafb5802ddd29f5112b6e"
  #source  = "cookpad/eks/aws//modules/iam"
  #version = "~> 1.23"

  service_role_name = "NetEksServiceRole"
  node_role_name    = "NetEksNode"
}

data "aws_iam_role" "FederatedAdmin" {
  name = "FederatedAdmin"
}

data "aws_iam_role" "NocAdmin" {
  name = "NocAdmin"
}

data "aws_iam_role" "OrgzAdmin" {
  name = "OrgzAdmin"
}
