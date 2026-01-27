
variable "repo" {
  type        = string
  description = "Git project repo path (this should be an env variable set in the pipeline)"
}

variable "environment" {
  type        = string
  description = "environment name"
}

variable "region" {
  type        = string
  description = "Default region"
  default     = "eu-west-1"
}
