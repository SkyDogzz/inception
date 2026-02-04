FROM alpine:3.23

RUN apk add --no-cache vsftpd

COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 21 30000-30009

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
