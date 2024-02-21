resource "helm_release" "load-balancer-controller" {
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.1" # 2.7.0

  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  # SA has to be created manually to enable eks pod iam role
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.load-balancer-controller.metadata.0.name
  }
  set {
    name  = "clusterName"
    value = "rk23"
  }
}

data "aws_iam_policy" "nocadmin-base" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "load-balancer-controller" {
  name                 = "NwLoadBalancerController"
  description          = "cookpad-nw k8s/aws_iam_role.load-balancer-controller"
  assume_role_policy   = data.aws_iam_policy_document.load-balancer-controller-trust.json
  permissions_boundary = data.aws_iam_policy.nocadmin-base.arn
}

data "aws_iam_policy_document" "load-balancer-controller-trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.cluster.oidc_config.arn]
    }
    condition {
      test     = "StringEquals"
      variable = module.cluster.oidc_config.condition
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role_policy" "load-balancer-controller" {
  role   = aws_iam_role.load-balancer-controller.name
  name   = "load-balancer-controller"
  policy = data.http.load-balancer-controller-policy.response_body
}

data "http" "load-balancer-controller-policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/d0c13bf1576965a3b65fc09ebce94ed9f86833a2/docs/install/iam_policy.json"

  lifecycle {
    postcondition {
      condition     = sha512(self.response_body) == "4060d7ffb2b476440950ffa908bee9b6ffbe5197e22e04a25b200a2da8f4ec23bbafbd07c3af922d38403309d27738aa624593566eb14b5dea2393e2d2d73f65"
      error_message = "checksum mismatch"
    }
  }
}

resource "kubernetes_service_account" "load-balancer-controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.load-balancer-controller.arn
      "eks.amazonaws.com/sts-regional-endpoints" = true
    }
  }
  automount_service_account_token = true
}

resource "kubernetes_labels" "pod-readiness-gate-inject" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "default"
  }
  labels = {
    # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/pod_readiness_gate/
    "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
  }
}

# module.cluster.oidc_config.url
# module.cluster.oidc_config.arn
# module.cluster.oidc_config.condition
