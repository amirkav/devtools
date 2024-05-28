# I use PyEnv to manage multiple python installations and virtual environments.

### Install PyEnv
# Follow instructions here to install PyEnv: https://github.com/pyenv/pyenv
brew install pyenv
brew install pyenv-virtualenv

# Add the following to ~/.zprofile
export PYENV_ROOT="$HOME/.pyenv"

# Restart shell
exec "$SHELL"

command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

### Install Python
# You can now install python versions using pyenv
pyenv install 3.10.0

# list of available python versions
pyenv install -l

# Get the list of python versions that are installed by pyenv on your machine
pyenv versions

### Create Virtual Env
# Create virtual environments using pyenv (option a)
# Pyenv stores the virtual envs in a central directory, not inside the project directory.
# If you plan to create separate venvs for different repositories, include the repo name in the venv name.
# But, pyenv still creates the venv inside the puyenv-root directory (you can't specify the path in the venv name).
# If you want to create the virtual env inside your project directory, you need a different workflow (read option b)
pyenv virtualenv 3.10.0 my-virtual-env

# Create virtual environments using pyenv (option b)
# If you want to create the venv directory inside your project repo, and have pyenv manage it, you need to:
# i. create a venv inside any directory you want
cd $PROJ_DIR
python -m venv ./.venv
# ii. link the venv to an available pyenv python installation
ln -s ./.venv ~/.pyenv/versions/my-virtual-env

### Use Virtual Envs
# You can now activate the virtual environment using pyenv
pyenv activate my-virtual-env

# You can now deactivate the virtual environment using pyenv
pyenv deactivate

# To delete the virtual environment using pyenv
pyenv uninstall my-virtual-env

# To delete the python version using pyenv
pyenv uninstall 3.10.0

# You can switch between python versions using pyenv
# To automatically activate local env when you enter your local development folder of your project, you have two options:
# (a) `pyenv global` reads/writes the ~/.python-version file. In the absence of any other clues, pyenv uses this file to determine which python version to use.
# (b) `pyenv local` selects what Python version to use in the current directory or its subdirectories.
# (c) `pyenv shell` sets the PYENV_VERSION environment variable for that shell. AKA it's equivalent to export PYENV_VERSION=3.9.1 for example. That means that this is temporary - when the shell exits, this command is lost until next time.
pyenv global 3.10.0
pyenv local 3.10.0

# More on using Pyenv with virtual envs:
# - https://medium.com/codex/python-version-management-with-pyenv-and-pyenv-virtualenv-linux-ecd6578b7bbf
# - https://github.com/pyenv/pyenv-virtualenv#activate-virtualenv
# - https://stackoverflow.com/questions/77338439/is-there-a-difference-between-pyenv-activate-and-pyenv-local
