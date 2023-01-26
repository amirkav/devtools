# Install nvm
echo 'Installing nvm by using homebrew'
brew install nvm

# From nvm
# Please note that upstream has asked us to make explicit managing
# nvm via Homebrew is unsupported by them and you should check any
# problems against the standard nvm install method prior to reporting.

# You should create NVM's working directory if it doesn't exist:

echo "Creating NVM's working directory it if doesn't exist"
mkdir ~/.nvm

echo 'Add the following to ~/.zshrc or your desired shell
configuration file:'

echo 'export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
'
