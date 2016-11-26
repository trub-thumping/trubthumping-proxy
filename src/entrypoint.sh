#!/usr/bin/env sh

set -a
set -x
set -e

cat > /haproxy.cfg <<EOF
global
        log 127.0.0.1   local0
        log 127.0.0.1   local1 notice
        maxconn 4096
        tune.ssl.default-dh-param 2048
        user haproxy
        group haproxy

        ssl-default-bind-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        option forwardfor
        option http-server-close
        stats enable
        stats auth ${HAPROXY_USERNAME}:${HAPROXY_PASSWORD}
        stats uri /stats

        retries                 3
        timeout http-request    10s
        timeout queue           1m
        timeout connect         10s
        timeout client          1m
        timeout server          1m
        timeout http-keep-alive 10s
        timeout check           10s

frontend http-in
         bind :80
         redirect scheme https code 301 if !{ ssl_fc }

frontend https-in
        bind :443 ssl crt /ssl/cert.pem
        reqadd X-Forwarded-Proto:\ https
        default_backend www-backend
        default_backend ghost

backend ghost
        server localhost ${GHOST_PORT_2368_TCP_ADDR}:${GHOST_PORT_2368_TCP_PORT}

EOF

cat /haproxy.cfg

exec haproxy -V -f /haproxy.cfg
