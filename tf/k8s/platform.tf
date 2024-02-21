resource "kubernetes_namespace" "platform" {
  metadata {
    name = "platform"
  }
}
