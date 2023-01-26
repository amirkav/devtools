#!/usr/bin/env sh

### Install Poetry for Python packange management
# Follow the instructions: https://python-poetry.org/docs/
curl -sSL https://install.python-poetry.org | python3 -

# Add the following to your ~/.zprofile:
export PATH="/Users/ak/.local/bin:$PATH"

### Poetry auto-complete
# Add Poetry auto-complete to oh-my-zsh 
mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry

# Add the following to ~/.zshrc 
'''
plugins(
	poetry
	...
	)

'''
