# modules/efs/main.tf
# This module defines the Amazon EFS file system and its mount targets.

resource "aws_efs_file_system" "main" {
  creation_token   = var.name # A unique string to identify the file system
  performance_mode = "generalPurpose" # Can be 'generalPurpose' or 'maxIo'
  encrypted        = true # It's good practice to encrypt EFS
  kms_key_id       = var.kms_key_arn # Optional: ARN of a custom KMS key for encryption

  tags = {
    Name = var.name
    VPC  = var.vpc_id # Tag EFS with the VPC ID for easy identification
  }
}

# Create an EFS mount target in each private subnet provided.
# The 'for_each' meta-argument iterates over the map of subnet IDs (keyed by AZ)
# passed from the root module, ensuring a unique mount target per AZ/subnet.
resource "aws_efs_mount_target" "main" {
  for_each        = var.subnet_ids # Iterate over the map of private subnet IDs (keyed by AZ)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.value # The subnet ID is accessed as the 'value' of the map element
  security_groups = var.security_group_ids # A list of security group IDs to apply to the mount target

  depends_on = [aws_efs_file_system.main] # Explicit dependency for clarity, though often inferred
}
