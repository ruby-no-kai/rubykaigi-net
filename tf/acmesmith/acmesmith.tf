locals {
  image = "005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/acmesmith:fe83993cab51662cf5be27f802b8cf126631556d"

  hosted_zones = [data.aws_route53_zone.rubykaigi_net]
  hosted_zone_map = {
    for z in local.hosted_zones : "${z.name}." => "/hostedzone/${z.zone_id}"
  }
}

data "aws_route53_zone" "rubykaigi_net" {
  name         = "rubykaigi.net."
  private_zone = false
}

data "aws_s3_bucket" "rubykaigi-public" {
  bucket = "rubykaigi-public"
}

data "external" "letsencrypt-staging" {
  program = ["${path.module}/../jsonnet.rb"]
  query = {
    path = "${path.module}/letsencrypt.jsonnet"
    args = jsonencode({
      staging         = true
      hosted_zone_map = local.hosted_zone_map
      bucket          = data.aws_s3_bucket.rubykaigi-public.bucket
    })
  }
}

data "external" "letsencrypt" {
  program = ["${path.module}/../jsonnet.rb"]
  query = {
    path = "${path.module}/letsencrypt.jsonnet"
    args = jsonencode({
      staging         = false
      hosted_zone_map = local.hosted_zone_map
      bucket          = data.aws_s3_bucket.rubykaigi-public.bucket
    })
  }
}

resource "kubernetes_config_map_v1" "letsencrypt-staging" {
  metadata {
    name      = "acmesmith-letsencrypt-staging"
    namespace = "default"
  }
  data = {
    "acmesmith.yml" = data.external.letsencrypt-staging.result.json
  }
}

resource "kubernetes_config_map_v1" "letsencrypt" {
  metadata {
    name      = "acmesmith-letsencrypt"
    namespace = "default"
  }
  data = {
    "acmesmith.yml" = data.external.letsencrypt.result.json
  }
}

resource "kubernetes_service_account_v1" "acmesmith" {
  metadata {
    name      = "acmesmith"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.acmesmith.arn
      "eks.amazonaws.com/sts-regional-endpoints" = true
    }
  }
}

resource "kubernetes_role_v1" "acmesmith" {
  metadata {
    name      = "acmesmith"
    namespace = "default"
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "patch", "update"]
  }
}

resource "kubernetes_role_binding_v1" "acmesmith" {
  metadata {
    name      = "acmesmith"
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.acmesmith.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.acmesmith.metadata[0].name
    namespace = "default"
  }
}

resource "kubernetes_job_v1" "new-account" {
  for_each = tomap({
    letsencrypt-staging = kubernetes_config_map_v1.letsencrypt-staging
    letsencrypt         = kubernetes_config_map_v1.letsencrypt
  })

  metadata {
    name      = "acmesmith-new-account-${each.key}"
    namespace = "default"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name  = "acmesmith"
          image = local.image
          args = [
            "new-account", "--ensure",
            "-c", "/config/acmesmith/acmesmith.yml",
            "mailto:info@rubykaigi.org",
          ]
          volume_mount {
            name       = "config"
            mount_path = "/config/acmesmith"
            read_only  = true
          }
        }
        volume {
          name = "config"
          config_map {
            name = each.value.metadata[0].name
          }
        }
        service_account_name = kubernetes_service_account_v1.acmesmith.metadata[0].name
        restart_policy       = "Never"
      }
    }
  }

  wait_for_completion = false
}

resource "kubernetes_cron_job_v1" "autorenew" {
  for_each = tomap({
    letsencrypt-staging = kubernetes_config_map_v1.letsencrypt-staging
    letsencrypt         = kubernetes_config_map_v1.letsencrypt
  })

  metadata {
    name      = "acmesmith-autorenew-${each.key}"
    namespace = "default"
  }
  spec {
    schedule = "0 * * * *"
    job_template {
      metadata {}
      spec {
        template {
          metadata {}
          spec {
            container {
              name  = "acmesmith"
              image = local.image
              args = [
                "autorenew",
                "-c", "/config/acmesmith/acmesmith.yml",
                "-r", "1/2",
              ]
              volume_mount {
                name       = "config"
                mount_path = "/config/acmesmith"
                read_only  = true
              }
            }
            volume {
              name = "config"
              config_map {
                name = each.value.metadata[0].name
              }
            }
            service_account_name = kubernetes_service_account_v1.acmesmith.metadata[0].name
            restart_policy       = "Never"
          }
        }
      }
    }
  }
}

resource "kubernetes_job_v1" "order-resolver-rubykaigi-net" {
  for_each = tomap({
    letsencrypt = kubernetes_config_map_v1.letsencrypt
  })

  metadata {
    name      = "acmesmith-order-resolver-rubykaigi-net-${each.key}"
    namespace = "default"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name  = "acmesmith"
          image = local.image
          args = [
            "order", "--ensure",
            "-c", "/config/acmesmith/acmesmith.yml",
            "--key-type", "ec", "--elliptic-curve", "prime256v1",
            "resolver.rubykaigi.net",
            "192.50.220.164", "192.50.220.165",
            "2001:df0:8500:ca6d:53::0:c", "2001:df0:8500:ca6d:53:0::d",
          ]
          volume_mount {
            name       = "config"
            mount_path = "/config/acmesmith"
            read_only  = true
          }
        }
        volume {
          name = "config"
          config_map {
            name = each.value.metadata[0].name
          }
        }
        service_account_name = kubernetes_service_account_v1.acmesmith.metadata[0].name
        restart_policy       = "Never"
      }
    }
  }

  wait_for_completion = false
}
