#!/bin/sh
set -eu

DATA_DIR="/var/lib/mysql"
RUNTIME_DIR="/run/mysqld"
SOCKET="${RUNTIME_DIR}/mysqld.sock"

require_env() {
    name="$1"
    value="$(printenv "$name" || true)"
    if [ -z "$value" ]; then
        echo "Missing required env var: $name" >&2
        exit 1
    fi
}

sql_escape() {
    printf "%s" "$1" | sed "s/'/''/g"
}

init_db() {
    if [ -d "${DATA_DIR}/mysql" ]; then
        return 0
    fi

    require_env MYSQL_ROOT_PASSWORD
    require_env MYSQL_DATABASE
    require_env MYSQL_USER
    require_env MYSQL_PASSWORD

    mkdir -p "$DATA_DIR" "$RUNTIME_DIR"
    chown -R mysql:mysql "$DATA_DIR" "$RUNTIME_DIR"

    mariadb-install-db --user=mysql --datadir="$DATA_DIR"

    mariadbd --user=mysql --datadir="$DATA_DIR" --socket="$SOCKET" --skip-networking &
    pid="$!"

    i=0
    until mariadb --protocol=socket --socket="$SOCKET" -e "SELECT 1;" >/dev/null 2>&1; do
        i=$((i + 1))
        if [ "$i" -ge 30 ]; then
            echo "MariaDB init failed: server not ready." >&2
            kill "$pid" >/dev/null 2>&1 || true
            exit 1
        fi
        sleep 1
    done

    db_name="$(sql_escape "$MYSQL_DATABASE")"
    db_user="$(sql_escape "$MYSQL_USER")"
    db_pass="$(sql_escape "$MYSQL_PASSWORD")"
    root_pass="$(sql_escape "$MYSQL_ROOT_PASSWORD")"

    mariadb --protocol=socket --socket="$SOCKET" <<-SQL
        CREATE DATABASE IF NOT EXISTS \`${db_name}\`;
        CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_pass}';
        GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_pass}';
        FLUSH PRIVILEGES;
SQL

    mariadb-admin --protocol=socket --socket="$SOCKET" -uroot -p"$root_pass" shutdown
    wait "$pid"
}

init_db

# Ensure permissions even when an existing volume is mounted.
chown -R mysql:mysql "$DATA_DIR" "$RUNTIME_DIR"

exec mariadbd --user=mysql --datadir="$DATA_DIR" --socket="$SOCKET" --bind-address=0.0.0.0
