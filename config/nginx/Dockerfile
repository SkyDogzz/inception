FROM nginx:1.29-alpine

RUN apk add netcat-openbsd bc curl wget git bash openssl

RUN mkdir -p /certs && \
    openssl req -x509 -nodes -newkey rsa:4096 \
      -keyout /certs/privkey.pem \
      -out /certs/fullchain.pem \
      -days 365 \
      -subj "/CN=localhost"

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 443
