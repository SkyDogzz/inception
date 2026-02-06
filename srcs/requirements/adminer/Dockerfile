FROM alpine:3.23

RUN apk add --no-cache \
    php83 \
    php83-session \
    php83-mysqli \
    php83-pdo \
    php83-pdo_mysql \
    curl

RUN ln -sf /usr/bin/php83 /usr/bin/php

WORKDIR /var/www/html

ARG ADMINER_VERSION=4.8.1
RUN curl -fsSL \
    https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php \
    -o /var/www/html/index.php

ARG ADMINER_PORT
ENV ADMINER_PORT="${ADMINER_PORT}"
EXPOSE ${ADMINER_PORT}

CMD ["sh", "-c", "php -S 0.0.0.0:${ADMINER_PORT} -t /var/www/html"]
