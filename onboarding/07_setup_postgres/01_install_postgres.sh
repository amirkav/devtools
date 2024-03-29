# there are several ways to install postgres. See the documentation here:
# https://www.postgresql.org/download/macosx/
# On this tutorial we use homebrew to install postgres.

# Select the version of postgres you want to install (in this case 15)
brew install postgresql@15

# Follow the instructions that Homebrew installer prints out to you.
# You will need to add the following to your ~/.zprofile:
echo 'export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"' >> ~/.zprofile
export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"

