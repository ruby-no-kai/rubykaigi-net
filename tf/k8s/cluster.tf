module "cluster" {
  source = "github.com/cookpad/terraform-aws-eks?ref=1.34.0"

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

  fargate_namespaces = toset([
    "default-fargate", # dummy
    # "kube-system",
  ])

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

  coredns_configuration_values = jsonencode({
    "autoScaling" = { "enabled" = true },
    "topologySpreadConstraints" = [
      {
        "labelSelector" = {
          "matchLabels" = {
            "eks.amazonaws.com/component" = "coredns",
            "k8s-app"                     = "kube-dns",
          },
        },
        "matchLabelKeys" = [
          "pod-template-hash",
        ],
        "maxSkew"           = 1,
        "topologyKey"       = "topology.kubernetes.io/zone",
        "whenUnsatisfiable" = "ScheduleAnyway",
      }
    ],
  })

  vpc_cni_configuration_values = jsonencode({
    "env" = {
      "ENABLE_PREFIX_DELEGATION" = "true",
      "WARM_PREFIX_TARGET"       = "1",
    },
    "resources" = {
      "requests" = {
        "memory" = "64M",
      },
    },
  })

  ebs_csi_configuration_values = jsonencode({
    "controller" = {
      "topologySpreadConstraints" = [
        {
          "labelSelector" = {
            "matchLabels" = {
              "eks.amazonaws.com/component" = "csi-driver",
              "app"                         = "ebs-csi-controller",
            },
          },
          "matchLabelKeys" = [
            "pod-template-hash",
          ],
          "maxSkew"           = 1,
          "topologyKey"       = "topology.kubernetes.io/zone",
          "whenUnsatisfiable" = "ScheduleAnyway",
        }
      ],
    },
  })

  kube_proxy_configuration_values = jsonencode({
    "resources" = {
      "requests" = {
        "memory" = "64M",
      },
    },
  })
}
