#!/usr/bin/env bash

#######################################
### (Step 1) Install & Configure Homebrew

# Check to see if Homebrew is installed, and install it if it is not
command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew"; \
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; }

# Add Homebrew to path
echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /Users/ak/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/ak/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

#######################################
### (Step 2) Install jq
brew install jq

# install gpg
brew install gnupg gnupg2

echo 'Finished running install bash tools!'

###########################
### Add aliases, env vars, PATH
# Add the following to your .bash_profile or ~/.zprofile:
cat >> ~/.zprofile <<EOF
export GITS_DIR=${HOME}/gits
export CONF_DIR=${HOME}/.credentials
export AWS_REGION=us-west-2
export AWS_DEFAULT_REGION=us-west-2

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
$(/opt/homebrew/bin/brew shellenv)
# export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH
EOF

# TODO: add more env vars such as those required by pipenv
