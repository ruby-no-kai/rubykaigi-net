locals {
  solver = {
    dns01 = {
      cnameStrategy = "Follow"
      route53 = {
        region = "ap-northeast-1",
      },
    },
    selector = {
      dnsZones = sort(concat(tolist(local.zones), ["rubykaigi.org"]))
    },
  }
}

resource "kubernetes_manifest" "letsencrypt" {
  for_each = tomap({
    letsencrypt         = "https://acme-v02.api.letsencrypt.org/directory",
    letsencrypt-staging = "https://acme-staging-v02.api.letsencrypt.org/directory"
  })

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = each.key
    }

    spec = {
      acme = {
        server = each.value,
        email  = local.email,
        privateKeySecretRef = {
          name = "acme-${each.key}",
        },
        solvers = [local.solver],
      }
    }
  }

  depends_on = [helm_release.cert-manager]
}
