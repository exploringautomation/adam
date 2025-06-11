# modules/vpc/variables.tf
# This file defines the input variables for the VPC module

variable "project_name" {
  description = "A name for your project, used in resource naming."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the public subnets (one for each AZ)."
  type        = list(string)
  # Removed validation as it cannot reference other variables in this context.
  # Terraform will still catch dimension mismatches at plan/apply time.
}

variable "private_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the private subnets (one for each AZ)."
  type        = list(string)
  # Removed validation as it cannot reference other variables in this context.
}

variable "availability_zones" {
  description = "A list of AWS Availability Zones to deploy subnets into (e.g., [\"ap-south-1a\", \"ap-south-1b\"])."
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) > 1
    error_message = "Please provide at least two Availability Zones."
  }
}
