variable "deployer_role" {
  type        = string
  description = "Name of the deployer cluster role."
  default     = "deployer"
}

variable "name" {
  type        = string
  description = "The machine-readable name of the project."

  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.name))
    error_message = "Name should consist of only lower-case letters, numbers, underscores and dashes."
  }
}
