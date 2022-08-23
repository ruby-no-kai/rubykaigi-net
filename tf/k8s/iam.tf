module "iam" {
  source  = "cookpad/eks/aws//modules/iam"
  version = "~> 1.22"

  service_role_name = "NwEksServiceRole"
  node_role_name    = "NwEksNode"
}

data "aws_iam_role" "FederatedAdmin" {
  name = "FederatedAdmin"
}
