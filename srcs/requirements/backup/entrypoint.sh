#!/bin/sh
set -eu

BACKUP_DIR="${BACKUP_DIR:-/backups}"
CRON_SCHEDULE="${BACKUP_CRON:-0 2 * * *}"

mkdir -p "$BACKUP_DIR" /var/log

# Write root crontab for busybox crond
printf "%s /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1\n" "$CRON_SCHEDULE" >/etc/crontabs/root

if [ "${BACKUP_ON_START:-0}" = "1" ]; then
  /usr/local/bin/backup.sh >>/var/log/backup.log 2>&1
fi

exec crond -f -l 2
