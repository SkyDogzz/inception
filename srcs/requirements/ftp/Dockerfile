FROM alpine:3.23

RUN apk add --no-cache vsftpd gettext

COPY vsftpd.conf.template /etc/vsftpd/vsftpd.conf.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ARG FTP_PORT=21
ARG FTP_PASV_MIN_PORT=30000
ARG FTP_PASV_MAX_PORT=30009
EXPOSE ${FTP_PORT} ${FTP_PASV_MIN_PORT}-${FTP_PASV_MAX_PORT}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
