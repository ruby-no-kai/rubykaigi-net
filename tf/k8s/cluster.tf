module "cluster" {
  # https://github.com/cookpad/terraform-aws-eks/pull/325
  source = "github.com/sorah/terraform-aws-eks//modules/cluster?ref=5868115d4cc178a6ca7396251c13df4f608555fd"
  #source = "cookpad/eks/aws//modules/cluster"

  name = "rk22"

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
    }
  ]

  critical_addons_node_group_architecture    = "arm64"
  critical_addons_node_group_bottlerocket    = true
  critical_addons_node_group_instance_family = "general_purpose"
}
