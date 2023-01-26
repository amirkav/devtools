#!/usr/bin/env bash

#######################################
### Install iTerm2
brew install --cask iterm2

### Customize iTerm
# These steps depend on your preferences,
# so be sure to try a few different options to find the ones that work best for you.

# Install Material Design color palette for iTerm
export ITERM2_CUSTOM="$HOME/.iterm2/custom"
mkdir -p $ITERM2_CUSTOM
git clone https://github.com/MartinSeeler/iterm2-material-design.git ${ITERM2_CUSTOM:-~/.iterm2/custom}/plugins/material-design
# Then set the Color Preset to Material Design. See the guide here:
# https://github.com/MartinSeeler/iterm2-material-design#how-to-use-it

# Set background transparency in iTerm:
# https://stackoverflow.com/questions/48470804/iterm2-transparent-transparent-background-for-inactive-windows

# Use option + arrow keys to escape words:
# https://coderwall.com/p/h6yfda/use-and-to-jump-forwards-backwards-words-in-iterm-2-on-os-x

#######################################
### More productivity tips for iTerm, zsh, oh-my-zsh
# https://medium.com/@ivanaugustobd/your-terminal-can-be-much-much-more-productive-5256424658e8
# https://www.mokkapps.de/blog/boost-your-productivity-by-using-the-terminal-iterm-and-zsh/
# https://www.howtogeek.com/337861/instantly-open-a-full-screen-terminal-on-your-mac-using-a-keyboard-shortcut/
