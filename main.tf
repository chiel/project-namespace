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

resource "kubernetes_role_binding" "deployer_deployer" {
  metadata {
    name      = "deployer-deployer"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.deployer_role
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.deployer.metadata[0].name
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}
