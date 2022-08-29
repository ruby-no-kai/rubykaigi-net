module "node_general" {
  # https://github.com/cookpad/terraform-aws-eks/pull/325
  source = "github.com/cookpad/terraform-aws-eks//modules/asg_node_group?ref=5868115d4cc178a6ca7396251c13df4f608555fd"
  #source = "cookpad/eks/aws//modules/cluster"

  name = "nodes-general"
  labels = {
    "rubykaigi.org/node-group" = "general"
  }

  cluster_config = module.cluster.config

  architecture    = "arm64"
  bottlerocket    = true
  instance_family = "burstable"
  instance_size   = "medium"
}

module "node_onpremises" {
  # https://github.com/cookpad/terraform-aws-eks/pull/325
  source = "github.com/cookpad/terraform-aws-eks//modules/asg_node_group?ref=5868115d4cc178a6ca7396251c13df4f608555fd"
  #source = "cookpad/eks/aws//modules/cluster"

  name = "nodes-onpremises"
  labels = {
    "rubykaigi.org/node-group" = "onpremises"
  }
  taints = {
    "dedicated" = "onpremises:NoSchedule"
  }

  cluster_config = merge(module.cluster.config, {
    private_subnet_ids = {
      "ap-northeast-1c" = data.aws_subnet.main-onpremises-c.id
      "ap-northeast-1d" = data.aws_subnet.main-onpremises-d.id
    }
  })

  architecture    = "arm64"
  bottlerocket    = true
  instance_family = "burstable"
  instance_size   = "small"
}
