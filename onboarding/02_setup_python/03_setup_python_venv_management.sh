
# I use PyEnv to manage multiple python installations and virtual environments.

# Follow instructions here to install PyEnv: https://github.com/pyenv/pyenv
brew install pyenv

# Add the following to ~/.zprofile
export PYENV_ROOT="$HOME/.pyenv"

# Restart shell
exec "$SHELL"

command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

###
# You can now install python versions using pyenv
pyenv install 3.10.0

# list of available python versions
pyenv install -l

# Get the list of python versions that are installed by pyenv on your machine
pyenv versions

# You can now create virtual environments using pyenv
pyenv virtualenv 3.10.0 my-virtual-env

# You can now activate the virtual environment using pyenv
pyenv activate my-virtual-env

# You can now deactivate the virtual environment using pyenv
pyenv deactivate

# You can now delete the virtual environment using pyenv
pyenv uninstall my-virtual-env

# You can now delete the python version using pyenv
pyenv uninstall 3.10.0

# You can switch between python versions using pyenv
# `pyenv global` reads/writes the ~/.python-version file. In the absence of any other clues, pyenv uses this file to determine which python version to use.
# `pyenv shell` sets the PYENV_VERSION environment variable for that shell. AKA it's equivalent to export PYENV_VERSION=3.9.1 for example. That means that this is temporary - when the shell exits, this command is lost until next time.
pyenv global 3.10.0
pyenv local 3.10.0

