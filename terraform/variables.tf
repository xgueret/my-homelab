variable "github_token" {
  description = "The GitHub Personal Access Token."
  type        = string
  sensitive   = true
}

variable "repository_name" {
  description = "The name of the GitHub repository."
  type        = string
  default     = "my-homelab"
}

variable "repository_description" {
  description = "A description for the GitHub repository"
  type        = string
  default     = "Managed by Terraform: HomeLab is a personal project designed to manage and automate a home laboratory environment."
}

variable "visibility" {
  description = "The visibility of the GitHub repository (public or private)."
  type        = string
  default     = "public"
}