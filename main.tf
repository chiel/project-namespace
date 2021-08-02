resource "kubernetes_namespace" "this" {
  metadata {
    name = var.name

    labels = {
      "app.kubernetes.io/managed-by" : "terraform"
      "app.kubernetes.io/name" : var.name
    }
  }
}

resource "kubernetes_service_account" "deployer" {
  metadata {
    name      = "deployer"
    namespace = kubernetes_namespace.this.metadata[0].name

    labels = {
      "app.kubernetes.io/managed-by" : "terraform"
      "app.kubernetes.io/name" : "deployer"
    }
  }

  automount_service_account_token = false
}
