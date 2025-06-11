# main.tf
# This is your root configuration file, where you call the VPC module

module "my_network" {
  source = "../modules/vpc" # Path to your VPC module relative to this file

  # Use variables defined in variables.tf
  project_name            = var.project_name
  vpc_cidr_block          = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  availability_zones      = var.availability_zones
}

# Outputs from the module, exposed at the root level
output "generated_vpc_id" {
  description = "The ID of the created VPC"
  value       = module.my_network.vpc_id
}

output "generated_public_subnet_ids" {
  description = "The IDs of the created public subnets, keyed by AZ"
  value       = module.my_network.public_subnet_ids
}

output "generated_private_subnet_ids" {
  description = "The IDs of the created private subnets, keyed by AZ"
  value       = module.my_network.private_subnet_ids
}

output "generated_nat_gateway_ids" {
  description = "The IDs of the created NAT Gateways, keyed by AZ"
  value       = module.my_network.nat_gateway_ids
}

output "generated_public_security_group_id" {
  description = "The ID of the created public security group"
  value       = module.my_network.public_security_group_id
}

output "generated_private_security_group_id" {
  description = "The ID of the created private security group"
  value       = module.my_network.private_security_group_id
}
