resource "helm_release" "load-balancer-controller" {
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.8" # 2.4.6

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
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/4ecd10c76b559251dabf7c74421b04f0d5678a6c/docs/install/iam_policy.json"

  lifecycle {
    postcondition {
      condition     = sha512(self.response_body) == "adb65a821563336991123a2de8004cb7cf77a8638e201fe6417353881b4462b1583f3e12c79e041327a499dbfb20471611cfb5b33584e1d76d03fa6d82ff24ea"
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
