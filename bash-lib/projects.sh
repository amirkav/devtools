if [ "${__imported_projects}" -a "$1" != "reload" ]; then
    return
else
    __imported_projects=yes
fi

if [[ -n "${BASH_VERSION}" ]]; then
    lib_path="${BASH_SOURCE%/*}"
elif [[ -n "${ZSH_VERSION}" ]]; then
    lib_path="${0:A:h}"
else
    echo "ERROR: Running in unsupported shell. Supported shells are: bash, zsh" >&2
    exit 1
fi

source "${lib_path}/aws.sh"
source "${lib_path}/dynamodb.sh"

get-project-config () {
    require-cmd jq || return 1

    local usage="Usage: get-project-config [OPTIONS] <env> <project> [<expression>]"

    local raw=
    while [[ "$1" == -* ]]; do
        case "$1" in
          --help)
            echo "${usage}" >&2
            echo >&2
            echo "Options:" >&2
            echo "    --help" >&2
            echo "        This help message." >&2
            echo "    -r, --raw" >&2
            echo "        Format scalar results without double quotes." >&2
            echo "    --version" >&2
            echo "        Print version." >&2
            return 0
            ;;
          -r|--raw)
            raw=-r
            shift
            ;;
          --version)
            echo "get-project-config 1.0.0"
            return 0
            ;;
        esac
    done

    if [ "$#" -lt 2 ]; then
        echo "${usage}" >&2
        return 1
    fi

    local env="$1"
    local project="$2"
    local expression=".Item${3:+.$3}"

    local profile="${env}"

    aws-refresh-session "${profile}"
    aws --profile "${profile}" \
        dynamodb get-item \
            --consistent-read \
            --table-name configs \
            --key "{\"project_name\": {\"S\": \"${project}\"}}" | \
                unmarshal-dynamodb | \
                    jq ${raw} "${expression}"
}

get-active-projects () {
    require-cmd jq || return 1

    local usage="Usage: get-active-projects [OPTIONS] <env>"

    while [[ "$1" == -* ]]; do
        case "$1" in
          --help)
            echo "${usage}" >&2
            echo >&2
            echo "Options:" >&2
            echo "    --help" >&2
            echo "        This help message." >&2
            echo "    --version" >&2
            echo "        Print version." >&2
            return 0
            ;;
          --version)
            echo "get-active-projects 1.1.0"
            return 0
            ;;
        esac
    done

    if [ "$#" -lt 1 ]; then
        echo "${usage}" >&2
        return 1
    fi

    local env="$1"

    local profile="${env}"

    aws-refresh-session "${profile}"
    aws --profile "${profile}" \
        dynamodb scan \
            --consistent-read \
            --table-name configs \
            --filter-expression '#status IN (:active, :rsa)' \
            --projection-expression '#project_name' \
            --expression-attribute-names '{"#status": "status", "#project_name": "project_name"}' \
            --expression-attribute-values '{":active": {"S": "active"}, ":rsa": {"S": "rsa"}}' | \
                unmarshal-dynamodb | \
                    jq -r '.Items[][]'| \
                        sort
}

# vim:ft=bash
