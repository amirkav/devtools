#!/usr/bin/env bash
# macOS has changed the default shell to zsh starting with Catalina:
# https://support.apple.com/en-us/HT208050

# Read these articles if you are deciding whether to use zsh or bash:
# https://apple.stackexchange.com/questions/361870/what-are-the-practical-differences-between-bash-and-zsh
# https://www.howtogeek.com/362409/what-is-zsh-and-why-should-you-use-it-instead-of-bash/

# If your Mac does not already use zsh as the default sheel, 
# you can change the default shell to zsh using the following command:
chsh -s /bin/zsh

#######################################
### Install oh-my-zsh
# https://ohmyz.sh/#install
# https://github.com/ohmyzsh/ohmyzsh/wiki
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# When prompted whether to change default shell to zsh, select Yes.

### Install zsh plugins
# zsh shell command autocomplete suggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# install shell fuzzy autocomplete
brew install fzf

# add the zsh plugins to the list of plugins to load when zsh starts (inside ~/.zshrc)
```
plugins=(
git
zsh-autosuggestions
zsh-syntax-highlighting
)
```

#######################################
### More productivity tips for zsh, and oh-my-zsh
# https://www.freecodecamp.org/news/how-to-configure-your-macos-terminal-with-zsh-like-a-pro-c0ab3f3c1156/
# https://scriptingosx.com/2019/06/moving-to-zsh/


