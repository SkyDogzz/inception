#!/bin/sh
set -eu

FTP_USER="${FTP_USER:-ftpuser}"
FTP_PASSWORD="${FTP_PASSWORD:-ftppass}"

if ! id -u "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -h /var/www/html -s /sbin/nologin "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
echo "$FTP_USER" >/etc/vsftpd.userlist

mkdir -p /var/www/html
chown -R "$FTP_USER":"$FTP_USER" /var/www/html

exec vsftpd /etc/vsftpd/vsftpd.conf
