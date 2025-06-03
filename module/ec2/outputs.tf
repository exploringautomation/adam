output "instance_ids" {
  value = aws_instance.jenkins_instances[*].id
}
