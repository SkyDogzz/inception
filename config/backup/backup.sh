#!/bin/sh
set -eu

require_env() {
    name="$1"
    value="$(printenv "$name" || true)"
    if [ -z "$value" ]; then
        echo "Missing required env var: $name" >&2
        exit 1
    fi
}

require_env MYSQL_DATABASE
require_env MYSQL_USER
require_env MYSQL_PASSWORD

MYSQL_HOST="${MYSQL_HOST:-db}"
BACKUP_DIR="${BACKUP_DIR:-/backups}"
WP_PATH="${WP_PATH:-/var/www/html}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"
TS="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"

DB_FILE="$BACKUP_DIR/db_${MYSQL_DATABASE}_${TS}.sql.gz"
WP_FILE="$BACKUP_DIR/wp_files_${TS}.tar.gz"

tries=0
until mariadb-admin -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" ping --silent >/dev/null 2>&1; do
    tries=$((tries + 1))
    if [ "$tries" -ge 15 ]; then
        echo "MariaDB not reachable at ${MYSQL_HOST} after retries." >&2
        exit 1
    fi
    sleep 2
done

mysqldump -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
    | gzip > "$DB_FILE"

tar -czf "$WP_FILE" -C "$WP_PATH" .

if [ -n "$RETENTION_DAYS" ] && [ "$RETENTION_DAYS" -ge 1 ] 2>/dev/null; then
    find "$BACKUP_DIR" -type f -mtime "+$RETENTION_DAYS" -delete
fi
