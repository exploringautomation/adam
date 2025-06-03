resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")
}
