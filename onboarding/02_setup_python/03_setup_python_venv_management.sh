
# I use PyEnv to manage multiple python installations and virtual environments.

# Follow instructions here to install PyEnv: https://github.com/pyenv/pyenv
brew install pyenv

# Add the following to ~/.zprofile
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
