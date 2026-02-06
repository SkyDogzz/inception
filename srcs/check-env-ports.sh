#!/bin/sh
set -eu

ENV_FILE="${1:-.env}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing env file: $ENV_FILE" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

required_vars="NGINX_PORT WP_FPM_PORT ADMINER_PORT GATEAU_PORT REDIS_PORT DB_PORT FTP_PORT FTP_PASV_MIN_PORT FTP_PASV_MAX_PORT"
missing=""

for var in $required_vars; do
  value="$(printenv "$var" || true)"
  if [ -z "$value" ]; then
    missing="${missing} ${var}"
  fi
done

if [ -n "$missing" ]; then
  echo "Missing required port env vars in $ENV_FILE:${missing}" >&2
  exit 1
fi

cat <<'EOF'
  ____  ____  _____  _____  _____
 / ___||  _ \| ____|| ____|| ____|
 \___ \| |_) |  _|  |  _|  |  _|
  ___) |  __/| |___ | |___ | |___
 |____/|_|   |_____||_____||_____|
EOF
