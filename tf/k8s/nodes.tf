module "node_general" {
  source = "github.com/cookpad/terraform-aws-eks//modules/asg_node_group?ref=6c563053ff6031d40293a32d8123a702cc55e913"
  #source  = "cookpad/eks/aws//modules/asg_node_group"
  #version = "~> 1.23"

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
  source = "github.com/cookpad/terraform-aws-eks//modules/asg_node_group?ref=6c563053ff6031d40293a32d8123a702cc55e913"
  #source  = "cookpad/eks/aws//modules/asg_node_group"
  #version = "~> 1.23"

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
  min_size        = 1
}
