

#######################################
### Install awscli v1
# Use AWS CLI v2. Here is an article that explains why v2 is preferred to v1:
# https://docs.aws.amazon.com/cli/latest/userguide/cliv2-migration-changes.html
# AWS CLI v2 is no longer a python lib and does not require a specific boto3 version.
# AWS CLI v2 provides the option to run inside a Docker container.
# There are two different options for installing AWS CLI v2:
# Option 1: install as a max package: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Option 2: install as a Docker image and run inside a container
# Follow this guide to install AWS CLI v2:
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-docker.html

# Step 1: Install Docker by following the instructions here:
# https://docs.docker.com/desktop/install/mac-install/

# Step 2: run aws cli v2 commands
# Running any aws cli v2 command will automatically download the image 
# from aws repository and start it.
docker run --rm -it amazon/aws-cli --version

# Step 3: create a shell alias for ease of use
# The AWS CLI v2 docker commands start with `docker run --rm -it amazon/aws-cli `
# To make it easier to run them on your shell, add the following line to your 
# favorite shell profile:

# I use awsdkr to refer to containerized CLI. The non-containerized CLI uses `aws` alias.
alias awsdkr='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws -e AWS_PROFILE amazon/aws-cli'

# NOTE: Follow the latest installation instructions here.
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-docker.html
