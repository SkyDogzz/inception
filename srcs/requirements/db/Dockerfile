FROM alpine:3.23

RUN apk add --no-cache \
    mariadb \
    mariadb-client

RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY mariadb.conf /etc/my.cnf.d/zzz-custom.cnf

ARG DB_PORT=3306
RUN sed -i "s/^port=.*/port=${DB_PORT}/" /etc/my.cnf.d/zzz-custom.cnf
EXPOSE ${DB_PORT}

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
