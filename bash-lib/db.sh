if [ "${__imported_db}" -a "$1" != "reload" ]; then
    return
else
    __imported_db=yes
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
source "${lib_path}/projects.sh"
source "${lib_path}/utils.sh"

get-db-master-pass () {
    local usage="Usage: get-db-master-pass [OPTIONS] <aws-profile> <project>"

    local batch= clipboard=
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
            echo "    -c, --clipboard" >&2
            echo "        Copy password to clipboard on success." >&2
            echo "    --version" >&2
            echo "        Print version." >&2
            return 0
            ;;
          --version)
            echo "get-db-master-pass 1.0.1"
            return 0
            ;;
          -b|--batch)
            batch=-b
            shift
            ;;
          -c|--clipboard)
            clipboard=-c
            shift
            ;;
        esac
    done

    if [ "$#" -lt 2 ]; then
        echo "${usage}" >&2
        return 1
    fi

    if [ ! -t 1 ]; then
        # Force batch mode if no TTY:
        batch=-b
    fi

    local profile="$1"
    local project="$2"

    aws-refresh-session ${batch} "${profile}"

    local ssm_param_name="$(get-project-config -r "${profile}" "${project}" "${profile}.\"us-west-2\".master_pass_parameter")"

    local value="$(aws --profile "${profile}" ssm get-parameter --name "${ssm_param_name}" --with-decryption | jq -r '.Parameter.Value')"
    if [ -z "${value}" ]; then
        echo "Something went wrong fetching DB master password." >&2
        return 1
    else
        if [ -z "${batch}" ]; then
            if [ -n "${clipboard}" ]; then
                echo "Today's ${project} DB master password in ${profile} copied to clipboard." >&2
                echo -n "${value}" | pbcopy
            else
                echo "Today's ${project} DB master password in ${profile} is: ${value}" >&2
            fi
        else
            echo "${value}"
        fi
        return 0
    fi
}

get-db-endpoint-for-project () {
    require-cmd aws awscli || return 1
    require-cmd jq || return 1

    local usage="Usage: get-db-endpoint-for-project [OPTIONS] <env> <project>"

    local endpoint_type=db_ro_endpoint engine=aurora-mysql
    while [[ "$1" == -* ]]; do
        case "$1" in
          --help)
            echo "${usage}" >&2
            echo >&2
            echo "Options:" >&2
            echo "    --help" >&2
            echo "        This help message." >&2
            echo "    --engine" >&2
            echo "        Select from instances with this database engine." >&2
            echo "        (mysql, postgres, aurora-mysql, aurora-postgres)" >&2
            echo "    --reader" >&2
            echo "        Select read-only endpoint (default)." >&2
            echo "    --writer" >&2
            echo "        Select read-write endpoint." >&2
            echo "    --version" >&2
            echo "        Print version." >&2
            return 0
            ;;
          --version)
            echo "get-db-endpoint-for-project 1.0.0"
            return 0
            ;;
          --engine)
            engine="$2"
            shift
            ;;
          --reader)
            endpoint_type=db_ro_endpoint
            ;;
          --writer)
            endpoint_type=db_endpoint
            ;;
        esac
        shift
    done

    if [ "$#" -lt 2 ]; then
        echo "${usage}" >&2
        return 1
    fi

    local env="$1"
    local project="$2"

    local endpoint_key=
    case "${engine}" in
      mysql|aurora-mysql)
        endpoint_key="${endpoint_type}"
        ;;
      postgres|aurora-postgres)
        endpoint_key="postgresql_${endpoint_type}"
        ;;
      *)
        echo "ERROR: Unsupported database engine: ${engine}" >&2
        return 1
        ;;
    esac

    get-project-config "${env}" "${project}" | \
        jq -r ".${env}.\"us-west-2\".${endpoint_key}"
}

mysql-project-do () {
    local usage="Usage: mysql-project-do [OPTIONS] <env> <project> <command> <args>..."

    local reader_writer=--reader
    while [[ "$1" == -* ]]; do
        case "$1" in
          --help)
            echo "${usage}" >&2
            echo >&2
            echo "Options:" >&2
            echo "    --help" >&2
            echo "        This help message." >&2
            echo "    --reader" >&2
            echo "        Select read-only endpoint (default)." >&2
            echo "    --writer" >&2
            echo "        Select read-write endpoint." >&2
            echo "    --version" >&2
            echo "        Print version." >&2
            return 0
            ;;
          --version)
            echo "mysql-project-do 1.0.0"
            return 0
            ;;
          --reader)
            reader_writer=--reader
            shift
            ;;
          --writer)
            reader_writer=--writer
            shift
            ;;
        esac
    done

    if [ "$#" -lt 2 ]; then
        echo "${usage}" >&2
        return 1
    fi

    local env="$1" profile="$1"
    local project="$2"
    shift 2

    if [ "$#" -ge 1 ]; then
        local command="$1"
        shift
    else
        local command="${SHELL}"
    fi

    local bastion_host="${ALTITUDE_BASTION_HOSTS[${env}]:-${ALTITUDE_BASTION_HOST}}"

    aws-refresh-session ${batch} "${profile}"

    local db_host="$(get-db-endpoint-for-project ${reader_writer} --engine aurora-mysql "${env}" "${project}")"
    if [ -z "${db_host}" ]; then
        echo "ERROR: Unable to determine database endpoint for ${env}/${project}." >&2
        return 1
    fi
    local db_display_host="${db_host%%.*}"
    local db_port=3306
    local db_user=masteruser
    local db_password="$(get-db-master-pass --batch "${env}" "${project}")"
    if [ -z "${db_password}" ]; then
        echo "ERROR: Unable to determine database password for ${env}/${project}." >&2
        return 1
    fi
    local db_name="${project}_${env}"

    if [ -n "${bastion_host}" ]; then
        local conn_id="altnet-rds:${env}:${project}"
        local local_port=$(( 33000 + $(hash-int 1000 <<<"${conn_id}") ))

        if [ "${command}" = "${SHELL}" ]; then
            local sleep=60
            echo "NOTE: Connect to database within ${sleep} seconds." >&2
        else
            local sleep=5
        fi
        ssh -C -q -f -o "ExitOnForwardFailure yes" -L "${local_port}:${db_host}:${db_port}" "${bastion_host}" sleep "${sleep}"
        local mysql_host="127.0.0.1" mysql_tcp_port="${local_port}"
    else
        local mysql_host="${db_host}" mysql_tcp_port="${db_port}"
    fi

    MYSQL_HOST="${mysql_host}" MYSQL_TCP_PORT="${mysql_tcp_port}" \
    MYSQL_USER="${db_user}" MYSQL_PWD="${db_password}" MYSQL_DATABASE="${db_name}" \
    MYSQL_SSL="1" \
    PS1="(mysql-project-do) ${PS1}" \
        "${command}" "$@"
}

mysql-project () {
    require-cmd mysql || return 1

    local usage="Usage: mysql-project [OPTIONS] <env> <project>"

    local reader_writer=--reader
    while [[ "$1" == -* ]]; do
        case "$1" in
          --help)
            echo "${usage}" >&2
            echo >&2
            echo "Options:" >&2
            echo "    --help" >&2
            echo "        This help message." >&2
            echo "    --reader" >&2
            echo "        Select read-only endpoint (default)." >&2
            echo "    --writer" >&2
            echo "        Select read-write endpoint." >&2
            echo "    --version" >&2
            echo "        Print version." >&2
            return 0
            ;;
          --version)
            echo "mysql-project 1.0.1"
            return 0
            ;;
          --reader)
            reader_writer=--reader
            ;;
          --writer)
            reader_writer=--writer
            ;;
        esac
        shift
    done

    if [ "$#" -lt 2 ]; then
        echo "${usage}" >&2
        return 1
    fi

    local env="$1" profile="$1"
    local project="$2"
    shift 2

    local bastion_host="${ALTITUDE_BASTION_HOSTS[${env}]:-${ALTITUDE_BASTION_HOST}}"

    aws-refresh-session ${batch} "${profile}"

    local db_host="$(get-db-endpoint-for-project ${reader_writer} --engine aurora-mysql "${env}" "${project}")"
    if [ -z "${db_host}" ]; then
        echo "ERROR: Unable to determine database endpoint for ${env}/${project}." >&2
        return 1
    fi
    local db_display_host="${db_host%%.*}"
    local db_port=3306
    local db_user=masteruser
    local db_password="$(get-db-master-pass --batch "${env}" "${project}")"
    if [ -z "${db_password}" ]; then
        echo "ERROR: Unable to determine database password for ${env}/${project}." >&2
        return 1
    fi
    local db_name="${project}_${env}"

    if [ -n "${bastion_host}" ]; then
        local conn_id="altnet-rds:${env}:${project}"
        local local_port=$(( 33000 + $(hash-int 1000 <<<"${conn_id}") ))

        ssh -C -q -f -o "ExitOnForwardFailure yes" -L "${local_port}:${db_host}:${db_port}" "${bastion_host}" sleep 10
        mysql --host=127.0.0.1 --port="${local_port}" --user="${db_user}" "${db_password:+--password=${db_password}}" --prompt "\\u@${db_display_host}:\\d> " --database="${db_name}" "$@"
    else
        mysql --host="${db_host}" --port="${db_port}" --user="${db_user}" "${db_password:+--password=${db_password}}" --prompt "\\u@${db_display_host}:\\d> " --database="${db_name}" "$@"
    fi
}

function pg-project-do () {
    local usage="Usage: pg-project-do [OPTIONS] <env> <project> [<command> <args>...]"

    local engine=
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
            echo "pg-project-do 1.0.0"
            return 0
            ;;
        esac
        shift
    done

    if [ "$#" -lt 2 ]; then
        echo "${usage}" >&2
        return 1
    fi

    local env="$1" profile="$1"
    local project="$2"
    shift 2

    if [ "$#" -ge 1 ]; then
        local command="$1"
        shift
    else
        local command="${SHELL}"
    fi

    local bastion_host="${ALTITUDE_BASTION_HOSTS[${env}]:-${ALTITUDE_BASTION_HOST}}"

    aws-refresh-session ${batch} "${profile}"

    local db_host="$(get-db-endpoint-for-project ${reader_writer} --engine postgres "${env}" "${project}")"
    if [ -z "${db_host}" ]; then
        echo "ERROR: Unable to determine ${engine:-database} endpoint for ${env}/${project}." >&2
        return 1
    fi
    local db_display_host="${db_host%%.*}"
    local db_port=5432
    local db_user=postgres
    local db_password="$(get-db-master-pass --batch "${env}" "${project}")"
    if [ -z "${db_password}" ]; then
        echo "ERROR: Unable to determine database password for ${env}/${project}." >&2
        return 1
    fi
    local db_name="${project}_${env}"

    if [ -n "${bastion_host}" ]; then
        local conn_id="altnet-rds:${env}:${project}"
        local local_port=$(( 54000 + $(hash-int 1000 <<<"${conn_id}") ))

        if [ "${command}" = "${SHELL}" ]; then
            local sleep=60
            echo "NOTE: Connect to database within ${sleep} seconds." >&2
        else
            local sleep=5
        fi
        ssh -C -q -f -o "ExitOnForwardFailure yes" -L "${local_port}:${db_host}:${db_port}" "${bastion_host}" sleep "${sleep}"
        local pg_host="127.0.0.1" pg_port="${local_port}"
    else
        local pg_host="${db_host}" pg_port="${db_port}"
    fi

    local pgpassfile="${TMPDIR}/${db_host}:${db_port}.pgpass"
    echo -n >"${pgpassfile}"
    chmod u=rw,go= "${pgpassfile}"
    echo >>"${pgpassfile}" "${pg_host}:${pg_port}:*:${db_user}:${db_password/:/\\:}"

    PGHOST="${pg_host}" PGPORT="${pg_port}" \
    PGUSER="${db_user}" PGPASSFILE="${pgpassfile}" PGDATABASE="${db_name}" \
    PGSSLMODE="prefer" \
    PS1="(pg-project-do) ${PS1}" \
        "${command}" "$@"

    rm -f "${pgpassfile}"
}

function psql-project () {
    require-cmd psql PostgreSQL || return 1

    local usage="Usage: psql-project [OPTIONS] <env> <project>"

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
            echo "psql-project 1.0.0"
            return 0
            ;;
        esac
        shift
    done

    if [ "$#" -lt 2 ]; then
        echo "${usage}" >&2
        return 1
    fi

    local env="$1"
    local project="$2"
    shift 2

    pg-project-do "${env}" "${project}" psql "$@"
}

# vim:ft=bash
