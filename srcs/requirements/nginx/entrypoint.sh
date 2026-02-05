#!/bin/sh
set -eu

: "${DOMAIN:?DOMAIN is required}"

envsubst '$DOMAIN' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec "$@"
