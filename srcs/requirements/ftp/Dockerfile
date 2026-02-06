FROM alpine:3.23

RUN apk add --no-cache vsftpd gettext

COPY vsftpd.conf.template /etc/vsftpd/vsftpd.conf.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ARG FTP_PORT
ARG FTP_PASV_MIN_PORT
ARG FTP_PASV_MAX_PORT
EXPOSE ${FTP_PORT} ${FTP_PASV_MIN_PORT}-${FTP_PASV_MAX_PORT}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
