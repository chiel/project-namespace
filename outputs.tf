# data "digitalocean_kubernetes_cluster" "this" {
#   name = var.kubernetes_cluster
# }

data "kubernetes_secret" "deployer_credentials" {
  metadata {
    name      = kubernetes_service_account.deployer.default_secret_name
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}

output "kubeconfig" {
  description = "Kubernetes configuration for the deployer service account, configured to deploy in the created namespace."
  value = yamlencode({
    "apiVersion" : "v1",
    "kind" : "Config",
    "current-context" : "default",
    "contexts" : [
      {
        "name" : "default",
        "context" : {
          "cluster" : "default"
          "namespace" : kubernetes_namespace.this.metadata[0].name,
          "user" : "default",
        },
      },
    ],
    "clusters" : [
      {
        "name" : "default",
        "cluster" : {
          "certificate-authority-data" : base64encode(data.kubernetes_secret.deployer_credentials.data["ca.crt"]),
          "server" : provider.kubernetes.host,
        },
      },
    ],
    "users" : [
      {
        "name" : "default",
        "user" : {
          "token" : data.kubernetes_secret.deployer_credentials.data.token,
        },
      },
    ],
  })
}
