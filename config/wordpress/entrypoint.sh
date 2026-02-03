#!/bin/sh
set -eu

WP="wp --path=/var/www/html --allow-root"

require_env() {
    name="$1"
    value="$(printenv "$name" || true)"
    if [ -z "$value" ]; then
        echo "Missing required env var: $name" >&2
        exit 1
    fi
}

setup_wp() {
    require_env MYSQL_DATABASE
    require_env MYSQL_USER
    require_env MYSQL_PASSWORD
    require_env WP_URL
    require_env WP_TITLE
    require_env WP_ADMIN_USER
    require_env WP_ADMIN_PASSWORD
    require_env WP_ADMIN_EMAIL
    require_env WP_USER
    require_env WP_USER_PASSWORD
    require_env WP_USER_EMAIL

    if echo "$WP_ADMIN_USER" | grep -qiE 'admin|administrator'; then
        echo "WP_ADMIN_USER must not contain 'admin' or 'administrator'." >&2
        exit 1
    fi

    if [ ! -f /var/www/html/wp-config.php ]; then
        $WP config create \
            --dbname="$MYSQL_DATABASE" \
            --dbuser="$MYSQL_USER" \
            --dbpass="$MYSQL_PASSWORD" \
            --dbhost="db" \
            --skip-check
    fi

    if [ -n "${WP_DEBUG:-}" ]; then
        $WP config set WP_DEBUG "${WP_DEBUG}" --raw
    fi
    if [ -n "${WP_DEBUG_LOG:-}" ]; then
        $WP config set WP_DEBUG_LOG "${WP_DEBUG_LOG}" --raw
    fi
    if [ -n "${WP_DEBUG_DISPLAY:-}" ]; then
        $WP config set WP_DEBUG_DISPLAY "${WP_DEBUG_DISPLAY}" --raw
    fi

    $WP config set WP_REDIS_HOST 'redis'
    $WP config set WP_REDIS_PORT '6379'

    i=0
    until nc -z db 3306 >/dev/null 2>&1; do
        i=$((i + 1))
        if [ "$i" -ge 60 ]; then
            echo "Database not ready after 60 attempts." >&2
            return 1
        fi
        sleep 2
    done

    if ! $WP core is-installed >/dev/null 2>&1; then
        $WP core install \
            --url="$WP_URL" \
            --title="$WP_TITLE" \
            --admin_user="$WP_ADMIN_USER" \
            --admin_password="$WP_ADMIN_PASSWORD" \
            --admin_email="$WP_ADMIN_EMAIL" \
            --skip-email
    fi

    if ! $WP user get "$WP_USER" >/dev/null 2>&1; then
        $WP user create "$WP_USER" "$WP_USER_EMAIL" \
            --user_pass="$WP_USER_PASSWORD" \
            --role=author
    fi

    i=0
    until nc -z redis 6379 >/dev/null 2>&1; do
        i=$((i + 1))
        if [ "$i" -ge 60 ]; then
            echo "Redis not ready after 60 attempts." >&2
            return 1
        fi
        sleep 2
    done

    $WP plugin activate redis-cache >/dev/null 2>&1 || true

    $WP redis enable >/dev/null 2>&1 || true
}

(
    setup_wp && echo "WordPress setup complete." || \
    echo "WordPress setup failed; php-fpm will still run." >&2
) &

exec php-fpm83 -F
