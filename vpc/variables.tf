variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1" # Change as needed
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "bibek-profile"
}

# variables.tf
# This file defines the input variables for your root configuration


variable "project_name" {
  description = "A unique name for your project, used to tag resources."
  type        = string
  default     = "my-terraform-project"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the main VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the public subnets (one for each AZ)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the private subnets (one for each AZ)."
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "A list of AWS Availability Zones to deploy subnets into."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"] # IMPORTANT: Verify these AZs exist in your chosen aws_region
}
