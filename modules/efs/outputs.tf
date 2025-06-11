# modules/efs/outputs.tf
# This module defines the output values for the EFS module.

output "efs_id" {
  description = "The ID of the EFS file system."
  value       = aws_efs_file_system.main.id
}

output "efs_arn" {
  description = "The ARN of the EFS file system."
  value       = aws_efs_file_system.main.arn
}

output "efs_dns_name" {
  description = "The DNS name of the EFS file system."
  value       = aws_efs_file_system.main.dns_name
}

output "efs_mount_target_ids" {
  description = "A map of EFS mount target IDs, keyed by Availability Zone."
  value       = { for az, mt in aws_efs_mount_target.main : az => mt.id }
}
