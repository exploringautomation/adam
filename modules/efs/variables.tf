# modules/efs/variables.tf
# This file defines the input variables for the EFS module.

variable "name" {
  description = "A unique name for the EFS file system."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the EFS will be created."
  type        = string
}

variable "subnet_ids" {
  description = "A map of private subnet IDs where EFS mount targets will be created, keyed by Availability Zone."
  type        = map(string) # Must be a map (AZ => ID) for 'for_each'
  validation {
    condition     = length(keys(var.subnet_ids)) > 0
    error_message = "At least one subnet ID must be provided for EFS mount targets."
  }
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the EFS mount targets."
  type        = list(string)
  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security group ID must be provided for EFS mount targets."
  }
}

variable "kms_key_arn" {
  description = "Optional: The ARN of the KMS key to use for EFS encryption."
  type        = string
  default     = null # If null, EFS will use an AWS-managed KMS key
}
