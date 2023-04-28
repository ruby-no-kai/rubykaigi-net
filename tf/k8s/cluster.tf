module "cluster" {
  #source  = "cookpad/eks/aws//modules/cluster"
  #version = "~> 1.23"
  source = "github.com/cookpad/terraform-aws-eks//modules/cluster?ref=6c563053ff6031d40293a32d8123a702cc55e913"

  name = "rk23"

  iam_config = module.iam.config
  vpc_config = {
    vpc_id = data.aws_vpc.main.id
    public_subnet_ids = {
      "ap-northeast-1c" = data.aws_subnet.main-public-c.id
      "ap-northeast-1d" = data.aws_subnet.main-public-d.id
    }
    private_subnet_ids = {
      "ap-northeast-1c" = data.aws_subnet.main-private-c.id
      "ap-northeast-1d" = data.aws_subnet.main-private-d.id
    }
  }

  endpoint_public_access = true

  aws_auth_role_map = [
    {
      username = data.aws_iam_role.FederatedAdmin.name
      rolearn  = data.aws_iam_role.FederatedAdmin.arn
      groups   = ["system:masters"]
    },
    {
      username = data.aws_iam_role.NocAdmin.name
      rolearn  = data.aws_iam_role.NocAdmin.arn
      groups   = ["system:masters"]
    },
    {
      username = data.aws_iam_role.OrgzAdmin.name
      rolearn  = data.aws_iam_role.OrgzAdmin.arn
      groups   = ["system:masters"]
    }
  ]

  critical_addons_node_group_architecture    = "arm64"
  critical_addons_node_group_bottlerocket    = true
  critical_addons_node_group_instance_family = "general_purpose"
}
