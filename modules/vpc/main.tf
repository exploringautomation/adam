# modules/vpc/main.tf
# This file defines the main resources for the VPC module

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create public subnets, one in each specified Availability Zone
resource "aws_subnet" "public" {
  for_each                = toset(var.availability_zones) # Iterate over the list of AZs
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_blocks[index(var.availability_zones, each.value)]
  availability_zone       = each.value
  map_public_ip_on_launch = true # Instances in this subnet will get a public IP
  tags = {
    Name = "${var.project_name}-public-${each.value}-subnet"
  }
}

# Create private subnets, one in each specified Availability Zone
resource "aws_subnet" "private" {
  for_each          = toset(var.availability_zones) # Iterate over the list of AZs
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_blocks[index(var.availability_zones, each.value)]
  availability_zone = each.value
  tags = {
    Name = "${var.project_name}-private-${each.value}-subnet"
  }
}

# Allocate an Elastic IP for each NAT Gateway (one per AZ)
resource "aws_eip" "nat_gateway_eip" {
  for_each = toset(var.availability_zones)
  vpc      = true # Required for NAT Gateway
  tags = {
    Name = "${var.project_name}-nat-eip-${each.value}"
  }
}

# Create a NAT Gateway for each Availability Zone
resource "aws_nat_gateway" "main" {
  for_each      = toset(var.availability_zones)
  allocation_id = aws_eip.nat_gateway_eip[each.value].id
  subnet_id     = aws_subnet.public[each.value].id # NAT Gateway must reside in a public subnet of its AZ
  tags = {
    Name = "${var.project_name}-nat-gateway-${each.value}"
  }
  # Removed the explicit 'depends_on' on aws_route_table_association.public
  # Terraform can often infer this dependency from the subnet_id reference.
  depends_on = [
    aws_internet_gateway.main,
  ]
}

# Single public route table (since all public subnets route to IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route for public subnets to send internet traffic via Internet Gateway
resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate each public subnet with the public route table
resource "aws_route_table_association" "public" {
  for_each       = toset(var.availability_zones)
  subnet_id      = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.public.id
}

# Create a private route table for each private subnet (one per AZ)
resource "aws_route_table" "private" {
  for_each = toset(var.availability_zones)
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-private-${each.value}-rt"
  }
}

# Route for each private subnet to send internet traffic via its respective NAT Gateway
resource "aws_route" "private_nat_gateway_route" {
  for_each               = toset(var.availability_zones)
  route_table_id         = aws_route_table.private[each.value].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[each.value].id # Point to the NAT Gateway in the same AZ
}

# Associate each private subnet with its specific private route table
resource "aws_route_table_association" "private" {
  for_each       = toset(var.availability_zones)
  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private[each.value].id
}

# Security Group for Public Subnet (e.g., for Web Servers or Load Balancer)
# Security Groups are regional, so only one is needed for all public subnets.
resource "aws_security_group" "public_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "${var.project_name}-public-sg"
  description = "Allow HTTP (Port 80) inbound from anywhere for public resources."

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-public-sg"
  }
}

# Security Group for Private Subnet (e.g., for Application Servers, NFS shares)
# Security Groups are regional, so only one is needed for all private subnets.
resource "aws_security_group" "private_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "${var.project_name}-private-sg"
  description = "Allow inbound traffic on port 8080 and 2049 from within the VPC."

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    # Allow traffic from any source within the VPC's CIDR block.
    # This is common for internal application communication (e.g., from an ALB in public subnet).
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp" # NFS commonly uses TCP, but UDP is also used
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-private-sg"
  }
}
