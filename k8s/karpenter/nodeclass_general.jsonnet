// module "node_general" {
//   source = "github.com/cookpad/terraform-aws-eks//modules/asg_node_group?ref=79d6a080cec911103cceafb5802ddd29f5112b6e"
//   #source  = "cookpad/eks/aws//modules/asg_node_group"
//   #version = "~> 1.23"
//
//   name = "nodes-general"
//   labels = {
//     "rubykaigi.org/node-group" = "general"
//   }
//
//   cluster_config = module.cluster.config
//
//   architecture    = "arm64"
//   bottlerocket    = true
//   instance_family = "burstable"
//   instance_size   = "medium"
//   min_size        = 4 # 2 per AZ
// }

(import './nodeclass.libsonnet') {
  metadata+: {
    name: 'general',
  },
}
