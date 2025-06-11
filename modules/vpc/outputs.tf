# modules/vpc/outputs.tf
# This file defines the output values for the VPC module

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# --- NEW OUTPUT ADDED HERE ---
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "A map of public subnet IDs, keyed by Availability Zone."
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}

output "private_subnet_ids" {
  description = "A map of private subnet IDs, keyed by Availability Zone."
  value       = { for az, subnet in aws_subnet.private : az => subnet.id }
}

output "nat_gateway_ids" {
  description = "A map of NAT Gateway IDs, keyed by Availability Zone."
  value       = { for az, nat_gw in aws_nat_gateway.main : az => nat_gw.id }
}

output "public_security_group_id" {
  description = "The ID of the security group for public subnet resources (e.g., web servers, load balancers)."
  value       = aws_security_group.public_sg.id
}

output "private_security_group_id" {
  description = "The ID of the security group for private subnet resources (e.g., application servers)."
  value       = aws_security_group.private_sg.id
}
