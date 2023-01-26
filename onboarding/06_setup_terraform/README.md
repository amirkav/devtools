# Terraform Installation

We manage local terraform installations via [tfenv](https://github.com/tfutils/tfenv)

`tfenv` operates similar to [rbenv](https://github.com/rbenv/rbenv) and [pyenv](https://github.com/pyenv/pyenv), allowing you to install and manage multiple versions of Terraform on your local machine.

## Prerequisites 
Make sure you've finished the steps in the [onboarding guide](../README.md), including getting [Keybase](https://keybase.io) installed.

Following [Hashicorp](https://keybase.io/hashicorp) in the Keybase app will allow `tfenv` to verify the signature of published hashes for Terraform versions(see [https://github.com/tfutils/tfenv#usage](https://github.com/tfutils/tfenv#usage)).

## Basic Usage
`tfenv` can be used to install specific versions:

``` sh
$ tfenv install 0.13.7
```

or the latest release:

``` sh
$ tfenv install latest
```

For more detailed instructions, see the [project README](https://github.com/tfutils/tfenv#usage)

# Known issues
Hashicorp recently migrated keys, and has yet to re-sign older Terraform binaries, so `tfenv` will produce the following error if attempting to install anything `< 0.13.7`:

``` sh
▶ ERROR openpgp: signature made by unknown entity
SHA256SUMS signature does not match!
```

see: [https://github.com/tfutils/tfenv/issues/265](https://github.com/tfutils/tfenv/issues/265)

Altitude currently uses `0.13.6` for infrastructure, so the installation script contains a workaround for installing the correct version, while still allowing `tfenv` to manage it.
