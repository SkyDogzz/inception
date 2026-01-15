FROM alpine:3.23

RUN apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-json \
    php83-openssl \
    php83-curl \
    php83-xml \
    php83-mbstring \
    php83-phar \
    php83-gd \
    php83-zip \
    curl \
    tar

RUN mkdir -p /var/www/html && \
    curl -fsSL https://wordpress.org/latest.tar.gz \
    | tar -xz --strip-components=1 -C /var/www/html

RUN sed -i \
    -e 's|^;listen =.*|listen = 9000|' \
    -e 's|^user =.*|user = nobody|' \
    -e 's|^group =.*|group = nobody|' \
    -e 's|^;clear_env = no|clear_env = no|' \
    /etc/php83/php-fpm.d/www.conf

WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm83", "-F"]
