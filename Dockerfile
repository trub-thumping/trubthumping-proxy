FROM alpine
MAINTAINER jspc <james@zero-internet.org.uk>

EXPOSE 443
expose 80

RUN  apk add --update --no-cache haproxy

COPY src/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
