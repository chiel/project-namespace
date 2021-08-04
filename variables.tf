variable "deployer_role" {
  type        = string
  description = "Name of the deployer cluster role."
  default     = "deployer"
}

variable "ghcr_token" {
  type        = string
  description = "Token that has read access to the GitHub Container Registry."
  sensitive   = true
}

variable "ghcr_user" {
  type        = string
  description = "User that has read access to the GitHub Container Registry."
}

variable "name" {
  type        = string
  description = "The machine-readable name of the project."

  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.name))
    error_message = "Name should consist of only lower-case letters, numbers, underscores and dashes."
  }
}

variable "kube_host" {
  type        = string
  description = "The hostname of the Kubernetes API."
}
