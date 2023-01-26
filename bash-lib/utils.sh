if [ "${__imported_utils}" -a "$1" != "reload" ]; then
    return
else
    __imported_utils=yes
fi

if [[ -n "${BASH_VERSION}" ]]; then
    lib_path="${BASH_SOURCE%/*}"
elif [[ -n "${ZSH_VERSION}" ]]; then
    lib_path="${0:A:h}"
else
    echo "ERROR: Running in unsupported shell. Supported shells are: bash, zsh" >&2
    exit 1
fi

require-cmd () {
    local command="$1"
    package="${2:-$1}"
    if type -p "${command}" >/dev/null; then
        return 0
    else
        echo "${command} required in PATH. Is ${package} installed?"
        return 1
    fi
}

HASH_COMMAND="${HASH_COMMAND:-gsha256sum}"

hash-int () {
    require-cmd "${HASH_COMMAND}" || return 1

    local modulo="${1:-$((2**32))}"

    local chars_needed=$(( $(printf '%x' "${modulo}" | wc -c) ))
    local hex_digits="$( "${HASH_COMMAND}" | cut -c "1-${chars_needed}" )"
    local remainder=$(( 16#${hex_digits} % ${modulo} ))
    echo "${remainder}"
}

read-user-input () {
    local prompt="$1"

    local user_input
    if [[ -n ${BASH_VERSION-} ]]; then
        read -p "${prompt}" user_input >&2
    elif [[ -n ${ZSH_VERSION-} ]]; then
        read "user_input?${prompt}" >&2
    else
        echo "ERROR: Running in unsupported shell. Supported shells are: bash, zsh" >&2
        return 1
    fi
    echo "${user_input}"
}

# vim:ft=bash
