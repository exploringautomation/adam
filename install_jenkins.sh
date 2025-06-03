#!/bin/bash

# Update system packages
sudo dnf update -y

# Install Java (Amazon Linux 2023 uses Corretto 17)
sudo dnf install -y java-17-amazon-corretto

# Add Jenkins repository
sudo tee /etc/yum.repos.d/jenkins.repo <<EOF
[jenkins]
name=Jenkins
baseurl=https://pkg.jenkins.io/redhat-stable
gpgcheck=1
enabled=1
EOF

# Import Jenkins GPG key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Jenkins
sudo dnf install -y jenkins

# Enable and start Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Verify Jenkins service status
sudo systemctl status jenkins

# Output initial admin password
echo "Initial Jenkins Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
