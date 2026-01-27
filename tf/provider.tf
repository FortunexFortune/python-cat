provider "aws" {

  default_tags {
    tags = {
      Terraform   = true
      repo        = var.repo
      environment = var.environment
    }
  }
}

