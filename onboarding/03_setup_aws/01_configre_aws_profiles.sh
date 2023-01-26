#!/usr/bin/env bash

# create the following three profiles in the ~/.aws/configs file
cat << EOF > ~/.aws/configs
[profile dev]
source_profile = dev
region = us-west-2

[profile staging]
source_profile = staging
region = us-west-2

[profile prod]
source_profile = prod
region = us-west-2
EOF

# add your credentials to ~/.aws/credentials file:
cat << EOF > ~/.aws/credentials
[dev]
aws_access_key_id = {{your_access_key_id_for_dev_aws_account}}
aws_secret_access_key = {{your_secret_access_key_for_dev_aws_account}}

[staging]
aws_access_key_id = {{your_access_key_id_for_staging_aws_account}}
aws_secret_access_key = {{your_secret_access_key_for_staging_aws_account}}

[prod]
aws_access_key_id = {{your_access_key_id_for_prod_aws_account}}
aws_secret_access_key = {{your_secret_access_key_for_prod_aws_account}}
EOF


echo "Finished add iam profiles!

###############################
Add the following to your .zprofile:

### AWS TOOLS
# Refresh ECR tokens
alias ecr='$(aws ecr get-login --no-include-email)'

# AWS DEV
alias dev='echo "Setting AWS_DEFAULT_PROFILE to DEV"; export AWS_DEFAULT_PROFILE=dev; export ENV=dev;'

# AWS STAGING
alias staging='echo "Setting AWS_DEFAULT_PROFILE to STAGING"; export AWS_DEFAULT_PROFILE=staging; export ENV=staging;'

# AWS PROD
alias prod='echo "Setting AWS_DEFAULT_PROFILE to PROD"; export AWS_DEFAULT_PROFILE=prod; export ENV=prod;'
"
