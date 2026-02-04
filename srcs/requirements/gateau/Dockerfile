FROM alpine:3.23

RUN apk add --no-cache apache2

COPY index.html /var/www/localhost/htdocs/index.html

EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]
