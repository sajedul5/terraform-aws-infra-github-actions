variable "region" {
  description = "Region for the AWS provider (IAM is global, so this only affects the API endpoint)"
  type        = string
  default     = "ap-southeast-2"
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the role, as owner/name"
  type        = string
  default     = "sajedul5/terraform-aws-infra-github-actions"
}

variable "branches" {
  description = "Branches whose push workflows may assume the role"
  type        = list(string)
  default     = ["main", "test", "dev"]
}

variable "environments" {
  description = "GitHub environments whose jobs may assume the role"
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "role_name" {
  description = "Name of the IAM role GitHub Actions assumes"
  type        = string
  default     = "github-actions-terraform-infra"
}

variable "state_bucket" {
  description = "S3 bucket holding the main stack's Terraform state (see ../backend.tf)"
  type        = string
  default     = "s3-terraform-state-files-backend"
}

variable "create_oidc_provider" {
  description = "Create the GitHub OIDC provider. Set to false if the account already has one."
  type        = bool
  default     = true
}
