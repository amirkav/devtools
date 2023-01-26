#!/usr/bin/env bash


#######################################
### (Step 1) Install tfenv
# tfenv lets you install a specific version of Terraform, and maintain multiple terraform versions on your machine.
# It lets you swithc between terraform versions.
# https://github.com/tfutils/tfenv

# Install tfenv via homebrew
brew install tfenv


#######################################
### (Step 2) Installed desired versions of Terraform
# Install the latest version
tfenv install latest

# Install a specific version
TFVER="0.15.2"
TEVER=`tfenv --version | awk '{print $2}'`
TFDIR="/usr/local/Cellar/tfenv/${TEVER}/versions/${TFVER}"

mkdir "${TFDIR}"
curl "https://releases.hashicorp.com/terraform/${TFVER}/terraform_${TFVER}_darwin_amd64.zip" --output "terraform_${TFVER}.zip"

unzip "terraform_${TFVER}.zip" -d "${TFDIR}"
rm -f "terraform_${TFVER}.zip"


#######################################
### (Step 3) Verify installations
# To verify the install, make sure you see ${TFVER} in the list below:
tfenv list

# Use 'tfenv use ${TFVER}' to activate that version
# to use the latest version:
tfenv use latest

# Verify the version was switched properly:
terraform version
