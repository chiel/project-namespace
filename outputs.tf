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
          "certificate-authority-data" : base64encode(kubernetes_secret.deployer.data["ca.crt"]),
          "server" : var.kube_host,
        },
      },
    ],
    "users" : [
      {
        "name" : "default",
        "user" : {
          "token" : kubernetes_secret.deployer.data.token,
        },
      },
    ],
  })
}

output "name" {
  description = "The name of the created namespace"
  value       = kubernetes_namespace.this.metadata[0].name
}
