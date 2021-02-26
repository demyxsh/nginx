#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

# Support old variables
[[ -n "${NGINX_DOMAIN:-}" ]] && DEMYX_DOMAIN="$NGINX_DOMAIN"
[[ -n "${NGINX_RATE_LIMIT:-}" ]] && DEMYX_RATE_LIMIT="$NGINX_RATE_LIMIT"

# Default variables
DEMYX_RATE_LIMIT_CONNECTION="#limit_conn addr 5;"
DEMYX_RATE_LIMIT_LOCATION="#limit_req zone=one burst=5 nodelay;"

# Cloudflare check
DEMYX_CLOUDFLARE_CHECK="$(curl -m 1 -svo /dev/null "${DEMYX_DOMAIN}" 2>&1 | grep "Server: cloudflare" || true)"
if [[ -n "$DEMYX_CLOUDFLARE_CHECK" ]]; then
    DEMYX_REAL_IP="real_ip_header CF-Connecting-IP; set_real_ip_from 0.0.0.0/0;"
else
    DEMYX_REAL_IP="real_ip_header X-Forwarded-For; set_real_ip_from 0.0.0.0/0;"
fi

# NGINX rate limiting
if [[ "$DEMYX_RATE_LIMIT" = on || "$DEMYX_RATE_LIMIT" = true ]]; then
    DEMYX_RATE_LIMIT_CONNECTION="limit_conn addr 5;"
    DEMYX_RATE_LIMIT_LOCATION="limit_req zone=one burst=5 nodelay;"
fi

echo "load_module /etc/nginx/modules/ngx_http_cache_purge_module.so;
load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;

error_log stderr notice;
error_log /var/log/nginx/error.log warn;
pid /tmp/nginx.pid;

worker_processes auto;
worker_cpu_affinity auto;
worker_rlimit_nofile 100000;
pcre_jit on;

events {
  worker_connections 4000;
  multi_accept on;
  accept_mutex on;
  use epoll;
}

http {
    log_format main '\$http_x_forwarded_for \$upstream_response_time \$upstream_cache_status [\$time_local] '
      '\$http_host \"\$request\" \$status \$body_bytes_sent '
      '\"\$http_referer\" \"\$http_user_agent\" \$server_protocol';

    client_max_body_size 128M;
    client_body_temp_path /tmp/nginx-client 1 2;
    fastcgi_temp_path /tmp/nginx-fastcgi 1 2;
    proxy_temp_path /tmp/nginx-proxy;
    uwsgi_temp_path /tmp/nginx-uwsgi;
    scgi_temp_path /tmp/nginx-scgi;
    fastcgi_read_timeout 120s;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log stdout;
    access_log /var/log/nginx/access.log  main;

    sendfile on;
    sendfile_max_chunk 512k;

    tcp_nopush on;
    tcp_nodelay on;

    keepalive_timeout 30;
    keepalive_requests 500;
    keepalive_disable msie6;

    lingering_time 20s;
    lingering_timeout 5s;

    server_tokens off;
    reset_timedout_connection on;
    send_timeout 2;

    resolver 1.1.1.1 1.0.0.1 valid=300s;
    resolver_timeout 10;

    limit_req_status 503;
    limit_req_zone \$request_uri zone=one:10m rate=1r/s;
    limit_conn_zone \$binary_remote_addr zone=addr:10m;

    gzip  off;

    add_header X-Powered-By \"Demyx - https://demyx.sh\";

    # Common security headers
    more_set_headers \"X-Frame-Options : SAMEORIGIN\";
    more_set_headers \"X-Xss-Protection : 1; mode=block\";
    more_set_headers \"X-Content-Type-Options : nosniff\";
    more_set_headers \"Referrer-Policy : strict-origin-when-cross-origin\";
    more_set_headers \"X-Download-Options : noopen\";

    server {
      listen       80;

      location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        $DEMYX_RATE_LIMIT_CONNECTION
        $DEMYX_RATE_LIMIT_LOCATION
      }

      error_page   500 502 503 504  /50x.html;
      location = /50x.html {
        root /usr/share/nginx/html;
      }

      $DEMYX_REAL_IP

      disable_symlinks off;
    }
}" > "$DEMYX_CONFIG"/nginx.conf
