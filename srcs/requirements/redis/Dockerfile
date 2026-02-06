FROM alpine:3.23

RUN apk add --no-cache redis

COPY redis.conf /etc/redis.conf

ARG REDIS_PORT=6379
RUN sed -i "s/^port .*/port ${REDIS_PORT}/" /etc/redis.conf
EXPOSE ${REDIS_PORT}

CMD ["redis-server", "/etc/redis.conf"]
