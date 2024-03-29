#!/usr/bin/env sh

### Install Poetry for Python packange management
# Follow the instructions: https://python-poetry.org/docs/
curl -sSL https://install.python-poetry.org | python3 -

# Add the following to your ~/.zprofile:
export PATH="/Users/ak/.local/bin:$PATH"

# Restart shell
exec "$SHELL"

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

# Note: poetry install pegs itself to the python version used to install it.
# If you want to use a different python version, you'll need to reinstall poetry.
# See: https://stackoverflow.com/questions/70920378/poetry-returns-dyld-library-not-loaded-image-not-found-following-brew-ins
