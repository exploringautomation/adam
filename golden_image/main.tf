module "vpc" {
  source = "./resources/vpc"
}

module "keypair" {
  source = "./resources/keypair"
}

module "security_group" {
  source = "./resources/security_group"
}

module "jenkins_ec2" {
  source            = "./module/ec2"
  #ami_id            = data.aws_ami.amazon_linux.id
  ami_id            = var.ami_id
  instance_type     = "t2.small"
  subnet_ids         = module.vpc.subnet_ids
  key_name          = module.keypair.key_name
  security_group_id = module.security_group.security_group_id
  volume_sizes      = [10, 20]
  instance_names    = ["master-Jenkins", "slave-Jenkins"]
}
