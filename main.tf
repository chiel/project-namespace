resource "kubernetes_namespace" "this" {
  metadata {
    name = var.name

    labels = {
      "app.kubernetes.io/managed-by" : "terraform"
      "app.kubernetes.io/name" : var.name
    }
  }
}

resource "kubernetes_network_policy" "deny_all" {
  metadata {
    name      = "deny-all"
    namespace = kubernetes_namespace.this.metadata[0].name

    labels = {
      "app.kubernetes.io/managed-by" : "terraform"
      "app.kubernetes.io/name" : "deny-all"
    }
  }

  spec {
    policy_types = ["Egress", "Ingress"]
    pod_selector {}
  }
}

resource "kubernetes_network_policy" "allow_cert_manager_solver" {
  metadata {
    name      = "allow-cert-manager-solver"
    namespace = kubernetes_namespace.this.metadata[0].name

    labels = {
      "app.kubernetes.io/managed-by" : "terraform"
      "app.kubernetes.io/name" : "allow-cert-manager-solver"
    }
  }

  spec {
    policy_types = ["Ingress"]

    pod_selector {
      match_labels = {
        "acme.cert-manager.io/http01-solver" : "true"
      }
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "app.kubernetes.io/name" : "ingress"
          }
        }
        pod_selector {
          match_labels = {
            "app.kubernetes.io/component" : "controller"
            "app.kubernetes.io/name" : "ingress-nginx"
          }
        }
      }
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

resource "kubernetes_secret" "deployer" {
  type = "kubernetes.io/service-account-token"

  metadata {
    name      = kubernetes_service_account.deployer.metadata[0].name
    namespace = kubernetes_namespace.this.metadata[0].name

    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.deployer.metadata[0].name
    }
  }
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

resource "kubernetes_secret" "ghcr_io" {
  type = "kubernetes.io/dockerconfigjson"

  metadata {
    name      = "ghcr.io"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" = {
        "https://ghcr.io" = {
          "auth" : base64encode("${var.ghcr_user}:${var.ghcr_token}")
        }
      }
    })
  }
}
