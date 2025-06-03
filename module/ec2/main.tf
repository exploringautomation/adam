resource "aws_instance" "jenkins_instances" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, count.index) # ✅ Corrected from subnet_ids
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  root_block_device {
    volume_size = element(var.volume_sizes, count.index)
  }

  tags = {
    Name = var.instance_names[count.index]
  }
}
