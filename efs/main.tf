# main.tf
# This configuration deploys an Amazon EFS file system into an existing VPC,
# identified by its 'Name' tag, and uses an existing security group.

# --- ESSENTIAL BLOCKS REQUIRED ---
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # This line tells Terraform to download an AWS provider compatible with 5.x
    }
  }
  required_version = ">= 1.0.0" # Best practice to define Terraform CLI version
}

# --- END ESSENTIAL BLOCKS REQUIRED ---


# --- Data Source: Fetch Existing VPC by its 'Name' Tag ---
# This block retrieves information about your existing VPC using the Name tag provided in variables.
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = [var.existing_vpc_name]
  }
}

# --- Data Source: Fetch IDs of Existing Private Subnets within the identified VPC ---
# This block specifically gets a LIST of IDs for subnets that match the criteria.
# We are using 'aws_subnets' (plural) here to get the 'ids' attribute.
data "aws_subnets" "matching_private_ids" {
  filter { # VPC ID is now a filter
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "map-public-ip-on-launch" # Private subnets usually don't map public IPs
    values = ["false"]
  }
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-private-*-subnet"]
  }
}

# --- Data Source: Fetch Details for Each Individual Private Subnet by ID ---
# This block iterates over the list of IDs obtained above and fetches the full
# details for each individual subnet, allowing us to get its Availability Zone.
data "aws_subnet" "individual_private_subnets" {
  for_each = toset(data.aws_subnets.matching_private_ids.ids) # Iterate over the list of IDs from aws_subnets.ids
  id       = each.value # Use the ID from the list to fetch each subnet's details
}

# --- Local: Transform private subnet data into the required map format ---
# This local block now iterates over the map of individual subnet objects (keyed by ID)
# and constructs the desired map keyed by Availability Zone.
locals {
  private_subnet_ids_by_az = {
    for id, s_obj in data.aws_subnet.individual_private_subnets : # Iterate over the map of individual subnet objects
    s_obj.availability_zone => s_obj.id
  }
}

# --- Data Source: Fetch Existing Security Group for EFS Mount Targets ---
# This block retrieves the ID of your existing security group by its name and VPC ID.
data "aws_security_group" "existing_efs_sg" {
  name   = var.existing_efs_sg_name # Use the variable for the existing SG's name
  vpc_id = data.aws_vpc.existing.id # Ensure it's in the correct existing VPC
}

# --- Module Call: Deploy EFS File System and Mount Targets ---
module "efs_file_system" {
  source = "../modules/efs"

  name               = "${var.project_name}-my-efs-storage"
  vpc_id             = data.aws_vpc.existing.id
  subnet_ids         = locals.private_subnet_ids_by_az
  security_group_ids = [data.aws_security_group.existing_efs_sg.id]
  # kms_key_arn      = "arn:aws:kms:YOUR_REGION:YOUR_ACCOUNT_ID:key/YOUR_KEY_ID"
}


# --- Outputs: Provide useful information about the deployed EFS and referenced infrastructure ---
output "referenced_vpc_id" {
  description = "The ID of the existing VPC being referenced by this configuration."
  value       = data.aws_vpc.existing.id
}

output "referenced_vpc_cidr_block" {
  description = "The CIDR block of the existing VPC being referenced."
  value       = data.aws_vpc.existing.cidr_block
}

output "referenced_private_subnet_ids" { # This output still uses locals.private_subnet_ids_by_az
  description = "The IDs of the existing private subnets being referenced, keyed by AZ."
  value       = locals.private_subnet_ids_by_az
}

output "referenced_efs_security_group_id" {
  description = "The ID of the existing security group used for EFS mount targets."
  value       = data.aws_security_group.existing_efs_sg.id
}

output "generated_efs_id" {
  description = "The ID of the created EFS file system."
  value       = module.efs_file_system.efs_id
}

output "generated_efs_arn" {
  description = "The ARN of the created EFS file system."
  value       = module.efs_file_system.efs_arn
}

output "generated_efs_dns_name" {
  description = "The DNS name of the EFS file system."
  value       = module.efs_file_system.efs_dns_name
}


# --- NEW DEBUGGING OUTPUTS ---
output "debug_vpc_id_found" {
  description = "DEBUG: The ID of the VPC found by the data source."
  value       = data.aws_vpc.existing.id
}

output "debug_matched_subnet_ids_list" {
  description = "DEBUG: The list of subnet IDs returned by data.aws_subnets."
  value       = data.aws_subnets.matching_private_ids.ids
}

output "debug_individual_subnets_map_content" {
  description = "DEBUG: The map of individual subnet objects fetched by data.aws_subnet (keyed by ID)."
  value       = data.aws_subnet.individual_private_subnets
}

output "debug_locals_map_result" {
  description = "DEBUG: The final map generated by the locals block (AZ to Subnet ID)."
  value       = locals.private_subnet_ids_by_az
}

output "debug_locals_map_is_empty" {
  description = "DEBUG: True if the locals map is empty, False otherwise."
  value       = length(keys(locals.private_subnet_ids_by_az)) == 0
}
