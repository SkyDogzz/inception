FROM alpine:3.23

RUN apk add --no-cache \
    nginx \
    netcat-openbsd \
    bc \
    curl \
    wget \
    git \
    bash \
    openssl \
    gettext

RUN mkdir -p /certs && \
    openssl req -x509 -nodes -newkey rsa:4096 \
      -keyout /certs/privkey.pem \
      -out /certs/fullchain.pem \
      -days 365 \
      -subj "/CN=localhost" && \
    mkdir -p /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ARG NGINX_PORT=443
EXPOSE ${NGINX_PORT}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
