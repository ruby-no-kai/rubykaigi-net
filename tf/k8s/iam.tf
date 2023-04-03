module "iam" {
  source  = "cookpad/eks/aws//modules/iam"
  version = "~> 1.23"

  service_role_name = "NetEksServiceRole"
  node_role_name    = "NetEksNode"
}

data "aws_iam_role" "FederatedAdmin" {
  name = "FederatedAdmin"
}

data "aws_iam_role" "NocAdmin" {
  name = "NocAdmin"
}
