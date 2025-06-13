#!/bin/bash

set -e

# Input arguments
EFS_ID=$1
REGION=$2

if [[ -z "$EFS_ID" || -z "$REGION" ]]; then
  echo "[ERROR] Usage: ./setup.sh <efs-id> <region>"
  exit 1
fi

echo "[INFO] Extracting jenkinsrole.tar"
tar -xvf /home/ubuntu/jenkinsrole.tar -C /home/ubuntu/

echo "[INFO] Installing Ansible"
sudo apt-get update -y
sudo apt-get install -y software-properties-common

# Add Ansible PPA if needed (for Ubuntu)
if ! command -v ansible &> /dev/null; then
  sudo apt-add-repository --yes --update ppa:ansible/ansible
  sudo apt-get install -y ansible
fi

echo "[INFO] Running Ansible Playbook with EFS ID: $EFS_ID and REGION: $REGION"
cd /home/ubuntu/jenkins-ansible

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook jenkins.yml \
  --extra-vars "efs_id=${EFS_ID} region=${REGION}"
