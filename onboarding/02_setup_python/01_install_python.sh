#!/usr/bin/env sh

#######################################
# Install python via homebrew
brew install python@3.11

######################################
# Add the following to your ~/.zprofile:
export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"

# Restart shell
exec "$SHELL"

# Test installation: the following commands should point to the Homebrew installation directory:
which python
which python3
