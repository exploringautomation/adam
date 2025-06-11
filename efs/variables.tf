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


variable "project_name" {
  description = "A unique name for your project, used to tag resources."
  type        = string
  default     = "my-terraform-project" # Set a default project name
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the main VPC."
  type        = string
  default     = "10.0.0.0/16" # Default VPC CIDR
}

variable "public_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the public subnets (one for each AZ)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"] # Default public subnet CIDRs for 2 AZs
}

variable "private_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the private subnets (one for each AZ)."
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"] # Default private subnet CIDRs for 2 AZs
}

variable "existing_vpc_name" {
  description = "The 'Name' tag value of the existing VPC where EFS should be deployed."
  type        = string
  default     = "my-terraform-project"
}

variable "existing_efs_sg_name" { # <--- NEW VARIABLE ADDED HERE
  description = "The name of the existing security group to associate with EFS mount targets."
  type        = string
  default     = "my-terraform-project-private-sg" # Default to the name you provided
}

variable "availability_zones" {
  description = "A list of AWS Availability Zones to deploy subnets into."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"] # Default AZs (verify these exist in your chosen region)
  validation {
    condition     = length(var.availability_zones) > 1
    error_message = "Please provide at least two Availability Zones."
  }
}
