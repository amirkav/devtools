#!/usr/bin/env bash

# A summary of what we are doing in this phase:
# 1. Generate a new PGP RSA key using Keybase.
# 2. Export the key to GPG.
# 3. Point Git to use the GPG key to sign commits.
# 4. Upload the key to Github to verify commits.

###############################################################################
### First, make sure Keybase is installed on your machine:
echo "Installing keybase and running keybase login"
keybase login | brew install --cask keybase

# If you install Keybase via Homebrew, you will need to allow a symlink
# to be created from /usr/local/sbin to the Applications folder where Keybase is installed.
# You can either create the Symlink manually, or follow these instructions.
echo "Verifying /usr/local/sbin exists or Creating it"
mkdir -p /usr/local/sbin

echo "Updating /usr/local/sbin access to everyone read/write"
chmod 777 /usr/local/sbin

brew link unbound

###############################################################################
### Generate a new key using Keybase PGP RSA algo
# When prompted to upload the secret to Keybase server, answer "No"
# When asked to encrypt the secret with a passphrase, answer "No"
echo "Runnning keybase pgp gen --multi. Enter keybase password when prompted"
keybase pgp gen --multi

###############################################################################
### Export the local key to GPG
# This assumes you have only a single PGP key in Keybase;
# if you have multiple keys, first use keybase pgp list to see the keys and
# their key IDs, then add -q <keyID> to the keybase pgp export command.
# https://blog.scottlowe.org/2017/09/06/using-keybase-gpg-macos/
echo "Exporting public key."
keybase pgp export | gpg --import

echo "Exporting secret key no passphrase"
keybase pgp export -s --unencrypted | gpg --allow-secret-key-import --import

echo "Fetching gpg secret key"
GPG_SK=$(gpg -K --keyid-format SHORT | grep sec | awk '{print $2}' | cut -d '/' -f 2)

###############################################################################
### Set Git to use the GPG key
echo "Setting git to use gpg secret key"
git config --global user.signingkey "${GPG_SK}"

echo "Enabling git gpgsign commits by default"
git config --global commit.gpgsign true

###############################################################################
### Add the Public GPG key to your Github account to use in verifying commits
echo "Adding GPG key to clipboard. Add this to Github -> Settings -> Add GPG Key"
gpg --armor --export "${GPG_SK}" | pbcopy

echo "Finished running signed commits script!

All your commits will now be signed with this computers key when pushing to a remote git repo
"
