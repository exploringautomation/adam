# versions.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify your desired AWS provider version range
    }
  }
  required_version = ">= 1.0.0" # Specify your desired Terraform CLI version
}
