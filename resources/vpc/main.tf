data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default_1a" {
  filter {
    name   = "availability-zone"
    values = ["ap-south-1a"]
  }
}

data "aws_subnet" "default_1b" {
  filter {
    name   = "availability-zone"
    values = ["ap-south-1b"]
  }
}

output "subnet_ids" {
  value = [data.aws_subnet.default_1a.id, data.aws_subnet.default_1b.id] # Only valid AZs
}
