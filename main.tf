resource "kubernetes_namespace" "this" {
  metadata {
    name = var.name

    labels = {
      "app.kubernetes.io/managed-by" : "terraform"
      "app.kubernetes.io/name" : var.name
    }
  }
}
