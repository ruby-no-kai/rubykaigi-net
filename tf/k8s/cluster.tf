module "cluster" {
  source = "github.com/cookpad/terraform-aws-eks?ref=70a90da1066f428a705b66a42266b6e482e818da"
  #source = "github.com/sorah/terraform-aws-eks?ref=tmp-2-29"

  name = "rknet"

  iam_role_name_prefix = "NetEks"

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
      username = data.aws_iam_role.NocAdmin.name
      rolearn  = data.aws_iam_role.NocAdmin.arn
      groups   = ["system:masters"]
    },
    {
      username = data.aws_iam_role.OrgzAdmin.name
      rolearn  = data.aws_iam_role.OrgzAdmin.arn
      groups   = ["system:masters"]
    },
    {
      username = "system:node:{{EC2PrivateDNSName}}"
      rolearn  = module.karpenter.node_role_arn
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]
}
