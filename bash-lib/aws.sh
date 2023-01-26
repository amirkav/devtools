if [ "${__imported_aws}" -a "$1" != "reload" ]; then
    return
else
    __imported_aws=yes
fi

if [[ -n "${BASH_VERSION}" ]]; then
    lib_path="${BASH_SOURCE%/*}"
elif [[ -n "${ZSH_VERSION}" ]]; then
    lib_path="${0:A:h}"
else
    echo "ERROR: Running in unsupported shell. Supported shells are: bash, zsh" >&2
    exit 1
fi

source "${lib_path}/utils.sh"

aws-profile-exists () {
    require-cmd aws awscli || return 1

    if [ "$#" -lt 1 ]; then
        echo "Usage: aws-profile-exists <aws-profile>" >&2
        return 1
    fi
    local profile="$1"
    aws --profile "${profile}" configure list >/dev/null 2>&1
    return $?
}

aws-refresh-session-mfa () {
    require-cmd aws awscli || return 1
    require-cmd gdate coreutils || return 1
    require-cmd jq || return 1

    local usage="Usage: aws-refresh-session-mfa [OPTIONS] <aws-profile> <aws-session-profile> <mfa-arn>"

    local batch=
    while [[ "$1" == -* ]]; do
        case "$1" in
          --help)
            echo "${usage}" >&2
            echo >&2
            echo "Options:" >&2
            echo "    --help" >&2
            echo "        This help message." >&2
            echo "    -b, --batch" >&2
            echo "        Script mode. Never prompt and log only the minimum necessary." >&2
            echo "    --version" >&2
            echo "        Print version." >&2
            return 0
            ;;
          --version)
            echo "aws-refresh-session-mfa 1.0.1"
            return 0
            ;;
          -b|--batch)
            batch=-b
            shift
            ;;
        esac
    done

    if [ "$#" -lt 3 ]; then
        echo "${usage}" >&2
        return 1
    fi

    if [ ! -t 1 ]; then
        # Force batch mode if no TTY:
        batch=-b
    fi

    local profile="$1"
    local session_profile="$2"
    local mfa_arn="$3"

    if ! aws-profile-exists "${profile}"; then
        # TODO: This assumes temporary-session management is tied to MFA auth, which it's really not.
        if [ -z "${batch}" ]; then
            echo "No MFA profile (${profile}) exists, so no need to request a session." >&2
        fi
        return 0
    fi

    local now="$(gdate +%s)"
    local session_expiration_str="$(aws --profile "${session_profile}" configure get session_expiration)"
    local session_expiration="$(gdate --date "${session_expiration_str}" +%s)"

    if [ "${session_expiration}" -ge "${now}" ]; then
        if [ -z "${batch}" ]; then
            echo "Your AWS session (${profile}/${session_profile}) is still good until ${session_expiration_str}." >&2
        fi
        return 0
    else
        # Refresh session token.
        local message="Your AWS session (${profile}/${session_profile}) has expired."
        if [ -n "${batch}" ]; then
            echo "ERROR: ${message} Cannot continue in batch mode." >&2
            return 1
        fi

        echo "${message}" >&2
        local mfa_token="$(read-user-input "Please enter an MFA token to refresh: ")"
        local creds_json="$(aws --profile "${profile}" sts get-session-token --serial-number "${mfa_arn}" --token-code "${mfa_token}")"
        if [ "$?" != 0 ]; then
            echo "Something went wrong getting a new session token. Aborting." >&2
            return 1
        fi

        local attrs=(
            'aws_access_key_id     AccessKeyId'
            'aws_secret_access_key SecretAccessKey'
            'aws_session_token     SessionToken'
            'session_expiration    Expiration'
        )
        for attr_map in "${attrs[@]}"; do
            local config_attr json_attr
            read config_attr json_attr <<<"${attr_map}"
            local value="$(jq -r ".Credentials.${json_attr}" <<<"${creds_json}")"
            aws --profile "${session_profile}" configure set "${config_attr}" "${value}"
        done

        echo "Your session is good until $(aws --profile "${session_profile}" configure get session_expiration)." >&2
    fi
    return 0
}

aws-refresh-session () {
    local usage="Usage: aws-refresh-session [OPTIONS] <aws-session-profile>"

    local batch= configure=
    while [[ "$1" == -* ]]; do
        case "$1" in
          --help)
            echo "${usage}" >&2
            echo >&2
            echo "Options:" >&2
            echo "    --help" >&2
            echo "        This help message." >&2
            echo "    -b, --batch" >&2
            echo "        Script mode. Never prompt and log only the minimum necessary." >&2
            echo "    --version" >&2
            echo "        Print version." >&2
            return 0
            ;;
          --version)
            echo "aws-refresh-session 1.0.0"
            return 0
            ;;
          -b|--batch)
            batch=-b
            shift
            ;;
          -c|--configure)
            configure=-c
            shift
            ;;
        esac
    done

    if [ "$#" -lt 1 ]; then
        echo "${usage}" >&2
        return 1
    fi

    if [ ! -t 1 ]; then
        # Force batch mode if no TTY:
        batch=-b
    fi

    local session_profile="$1"
    local profile="${session_profile}-mfa"

    if ! aws-profile-exists "${profile}"; then
        # TODO: This assumes temporary-session management is tied to MFA auth, which it's really not.
        if [ -z "${batch}" ]; then
            echo "No MFA profile (${profile}) exists, so no need to request a session." >&2
        fi
        return 0
    fi

    local mfa_arn
    if [ -z "${configure}" ]; then
        mfa_arn="$(aws --profile "${profile}" configure get mfa_arn)"
    else
        mfa_arn=""
    fi
    if [ -z "${mfa_arn}" ]; then
        # Prompt to configure MFA ARN.
        local message="No MFA ARN configured for AWS profile '${profile}'."
        if [ -n "${batch}" ]; then
            echo "ERROR: ${message}" >&2
            echo "Run interactively to configure." >&2
            return 1
        else
            echo "${message}" >&2
            mfa_arn="$(read-user-input "Please enter an MFA ARN: ")"
            aws --profile "${profile}" configure set mfa_arn "${mfa_arn}"
            echo "MFA ARN stored for AWS profile '${profile}'." >&2
            echo >&2
            if [ -n "${configure}" ]; then
                return 0
            fi
        fi
    fi

    if [ -z "${batch}" ]; then
        echo "Requesting session from profile '${profile}' using MFA ${mfa_arn}" >&2
    fi

    aws-refresh-session-mfa ${batch} "${profile}" "${session_profile}" "${mfa_arn}"
}

# vim:ft=bash
