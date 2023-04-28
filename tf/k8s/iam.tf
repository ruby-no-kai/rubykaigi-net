module "iam" {
  source = "github.com/cookpad/terraform-aws-eks//modules/iam?ref=6c563053ff6031d40293a32d8123a702cc55e913"
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
