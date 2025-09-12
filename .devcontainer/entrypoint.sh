#!/bin/bash
set -e

# Handle password file if specified
if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# Database configuration with defaults
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='postgres'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

# Build database arguments if not in config
DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\\n\\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}

check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

# Development-specific initialization
if [ "$1" = "odoo" ] || [ "$1" = "--" ]; then
    shift
    
    # Wait for database
    echo "Waiting for PostgreSQL..."
    python3 /usr/local/bin/wait-for-psql.py "${DB_ARGS[@]}" --timeout=30
    
    # Development mode enhancements
    if [ "${ODOO_DEV:-false}" = "true" ]; then
        echo "Starting Odoo in development mode..."
        exec odoo --dev=xml,reload,qweb,werkzeug,reload_on_update "$@" "${DB_ARGS[@]}"
    else
        exec odoo "$@" "${DB_ARGS[@]}"
    fi
elif [ "${1:0:1}" = "-" ]; then
    python3 /usr/local/bin/wait-for-psql.py "${DB_ARGS[@]}" --timeout=30
    exec odoo "$@" "${DB_ARGS[@]}"
else
    exec "$@"
fi

exit 1
