#!/bin/sh
set -eu

FTP_USER="${FTP_USER:-ftpuser}"
FTP_PASSWORD="${FTP_PASSWORD:-ftppass}"

require_env() {
  name="$1"
  value="$(printenv "$name" || true)"
  if [ -z "$value" ]; then
    echo "Missing required env var: $name" >&2
    exit 1
  fi
}

require_env FTP_PORT
require_env FTP_PASV_MIN_PORT
require_env FTP_PASV_MAX_PORT

if ! id -u "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -h /var/www/html -s /sbin/nologin "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
echo "$FTP_USER" >/etc/vsftpd.userlist

envsubst '$FTP_PORT $FTP_PASV_MIN_PORT $FTP_PASV_MAX_PORT' \
  </etc/vsftpd/vsftpd.conf.template >/etc/vsftpd/vsftpd.conf

mkdir -p /var/www/html
chown -R "$FTP_USER":"$FTP_USER" /var/www/html

exec vsftpd /etc/vsftpd/vsftpd.conf
