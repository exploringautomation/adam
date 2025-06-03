data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*"] # Amazon Linux 2023
  }
}
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

variable "ami_id" {
  type        = string
  description = "Amazon Linux 2023 AMI ID"
  default     = "ami-02a2af70a66af6dfb" # Latest Amazon Linux 2023 AMI for ap-south-1
}
