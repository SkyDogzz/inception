#!/bin/sh
set -eu

FTP_USER="${FTP_USER:-ftpuser}"
FTP_PASSWORD="${FTP_PASSWORD:-ftppass}"
FTP_PORT="${FTP_PORT:-21}"
FTP_PASV_MIN_PORT="${FTP_PASV_MIN_PORT:-30000}"
FTP_PASV_MAX_PORT="${FTP_PASV_MAX_PORT:-30009}"

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
