#!/bin/bash

# Update system packages
sudo dnf update -y

# Install Terraform
curl -O https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
sudo dnf install -y unzip
sudo unzip terraform_1.9.8_linux_amd64.zip -d /usr/local/bin/

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo dnf install -y unzip
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/bin --install-dir /usr/bin/aws-cli --update

# Install Packer
wget https://releases.hashicorp.com/packer/1.8.7/packer_1.8.7_linux_amd64.zip
sudo unzip packer_1.8.7_linux_amd64.zip -d /usr/local/bin/

# Install Trivy (Fixed for Amazon Linux 2023)
wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_$(uname -m).rpm
sudo rpm -ivh trivy_$(uname -m).rpm || {
    echo "Trivy RPM failed, trying manual installation..."
    latest_version=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep tag_name | awk -F'"' '{print $4}')
    wget https://github.com/aquasecurity/trivy/releases/download/${latest_version}/trivy_${latest_version}_Linux-64bit.tar.gz
    tar -xvzf trivy_${latest_version}_Linux-64bit.tar.gz
    sudo mv trivy /usr/local/bin/
}

# Install JRE (Amazon Corretto 17)
sudo dnf install -y java-17-amazon-corretto

# Verify installations
terraform version
aws --version
packer version
trivy --version
java -version

echo "Installation complete!"
