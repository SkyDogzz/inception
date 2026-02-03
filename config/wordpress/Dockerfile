FROM alpine:3.23

RUN apk add --no-cache \
    php83 \
    php83-fpm \
    php83-cli \
    php83-mysqli \
    php83-json \
    php83-openssl \
    php83-curl \
    php83-xml \
    php83-mbstring \
    php83-phar \
    php83-tokenizer \
    php83-gd \
    php83-zip \
    curl \
    tar \
    netcat-openbsd

RUN ln -sf /usr/bin/php83 /usr/bin/php

RUN mkdir -p /var/www/html && \
    curl -fsSL https://wordpress.org/latest.tar.gz \
    | tar -xz --strip-components=1 -C /var/www/html

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp && chmod +x /usr/local/bin/wp

RUN sed -i \
    -e 's|^;listen =.*|listen = 0.0.0.0:9000|' \
    -e 's|^listen = .*|listen = 0.0.0.0:9000|' \
    -e 's|^user =.*|user = nobody|' \
    -e 's|^group =.*|group = nobody|' \
    -e 's|^listen.allowed_clients =.*|;listen.allowed_clients = 127.0.0.1|' \
    -e 's|^;listen.allowed_clients =.*|;listen.allowed_clients = 127.0.0.1|' \
    -e 's|^;clear_env = no|clear_env = no|' \
    /etc/php83/php-fpm.d/www.conf

WORKDIR /var/www/html

EXPOSE 9000

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
