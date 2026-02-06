#!/bin/sh
set -eu

: "${DOMAIN:?DOMAIN is required}"

ADMINER_ALLOW_RULES=""
adminer_ips="${ADMINER_ALLOWED_IPS:-}"
if [ -z "$adminer_ips" ]; then
  adminer_ips="127.0.0.1,::1"
fi
rules=""
old_ifs="$IFS"
IFS=','
for ip in $adminer_ips; do
  ip="$(echo "$ip" | tr -d '[:space:]')"
  [ -z "$ip" ] && continue
  rules="${rules}allow ${ip};\n"
done
IFS="$old_ifs"
rules="${rules}deny all;"
ADMINER_ALLOW_RULES="$(printf "%b" "$rules")"
export ADMINER_ALLOW_RULES

envsubst '$DOMAIN $ADMINER_ALLOW_RULES $NGINX_PORT $ADMINER_PORT $GATEAU_PORT $WP_FPM_PORT' \
  </etc/nginx/nginx.conf.template >/etc/nginx/nginx.conf

exec "$@"
