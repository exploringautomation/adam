variable "ami_id" {}
variable "instance_type" {}
#variable "subnet_id" {}
variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets across different AZs"
}
variable "key_name" {}
variable "security_group_id" {}

variable "instance_names" {
  type    = list(string)
  default = ["master-Jenkins", "slave-Jenkins"]
}

variable "volume_sizes" {
  type    = list(number)
  default = [10, 20] # Master -> 10GB, Slave -> 20GB
}
