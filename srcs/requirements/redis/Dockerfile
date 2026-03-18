FROM alpine:3.22

RUN apk add --no-cache redis

COPY redis.conf /etc/redis.conf

ARG REDIS_PORT
ARG REDIS_PASSWORD
RUN sed -i "s/^port .*/port ${REDIS_PORT}/" /etc/redis.conf
RUN sed -i "s/^requirepass .*/requirepass ${REDIS_PASSWORD}/" /etc/redis.conf
EXPOSE ${REDIS_PORT}

CMD ["redis-server", "/etc/redis.conf"]
