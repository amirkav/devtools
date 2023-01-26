#!/usr/bin/env bash
ENV_FILE_NAME="~/.python.env"

set_aws_env_vars() {
    read -p 'ENV [dev]: ' ENV
    ENV=${ENV:-dev}
    
    read -p "AWS_DEFAULT_PROFILE [$ENV]: " AWS_DEFAULT_PROFILE
    AWS_DEFAULT_PROFILE=${AWS_DEFAULT_PROFILE:-$ENV}

    read -p 'AWS_REGION [us-west-2]: ' AWS_REGION
    AWS_REGION=${AWS_REGION:=us-west-2}

    read -p 'SUFFIX [01]: ' SUFFIX
    SUFFIX=${SUFFIX:-01}
}

set_aws_env_vars_zsh() {
    read "ENV?ENV [dev]: "
    export ENV=${ENV:-dev}
    
    read "AWS_DEFAULT_PROFILE?AWS_DEFAULT_PROFILE [$ENV]: "
    export AWS_DEFAULT_PROFILE=${AWS_DEFAULT_PROFILE:-$ENV}

    read "AWS_REGION?AWS_REGION [us-west-2]: "
    export AWS_REGION=${AWS_REGION:=us-west-2}

    read "SUFFIX?SUFFIX [01]: "
    export SUFFIX=${SUFFIX:-01}

    sed -i'.original' s/'\(ENV=\)\(.*\)/\1'"${ENV}"'/' ~/.python.env
    sed -i'.original' s/'\(AWS_DEFAULT_PROFILE=\)\(.*\)/\1'"${ENV}"'/' ~/.python.env
    sed -i'.original' s/'\(AWS_REGION=\)\(.*\)/\1'"${AWS_REGION}"'/' ~/.python.env
    sed -i'.original' s/'\(SUFFIX=\)\(.*\)/\1'"${SUFFIX}"'/' ~/.python.env
}
