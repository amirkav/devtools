#!/usr/bin/env bash

# MacOS comes with Apple vertion of Git installed:
# $ git --version
# Will print something like: `git version 2.32.1 (Apple Git-133)`
# Apple does not automatically update Git versions.
# Occasionally, Git updates are critical and fix important bugs.
# For that reason, it's best to keep our git versions up-to-date.

# You can install the latest version of Git via Homebrew:
brew update && brew upgrade
brew install git

# Verify that Homebrew's installation is being prioritized
which git
# Should return something like:
# /opt/homebrew/bin/git
