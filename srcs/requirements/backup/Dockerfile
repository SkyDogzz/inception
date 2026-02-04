FROM alpine:3.23

RUN apk add --no-cache \
    mariadb-client \
    tar \
    gzip \
    tzdata

COPY backup.sh /usr/local/bin/backup.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/backup.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
