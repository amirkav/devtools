#!/usr/bin/env bash

#######################################
### Set git pull strategy
# When running `git pull` to pull from origin, git will
# attempt one of the following strategies to merge the remote
# work with your local repo: rebase, merge, fast-forward.
# This command will set the default strategy. But, the pull
# method can still be override via `git pull --rebase` `git pull --merge`
# `git pull --fast-forward` flags.
# The reason we choose fast-forward-only as the default method is to
# enforce the policy of using feature branches and integrating code
# only via Pull Requests and code review. If you follow that guideline,
# and do not share development branches with other engineers,
# your local branch should always be able to be fast-forwarded to the remote.
# https://stackoverflow.com/questions/62653114/how-
# to-deal-with-this-git-warning-pulling-without-specifying-how-to-reconcile
git config --global pull.ff only

#######################################
### `git log` utility command
# git log is a powerful tool to view the commit history of a repo.
# This alias adds visual indentations to represent branches on and off of the trunk.
cat >> ~/.gitconfig <<EOF
[alias]
l = log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cblue[%an]%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative
la = !git l --all
EOF

# To see the end result:
git config --list
