FROM alpine:3.23

RUN apk add --no-cache apache2

COPY index.html /var/www/localhost/htdocs/index.html

ARG GATEAU_PORT=80
RUN sed -i "s/^Listen .*/Listen ${GATEAU_PORT}/" /etc/apache2/httpd.conf
EXPOSE ${GATEAU_PORT}

CMD ["httpd", "-D", "FOREGROUND"]
