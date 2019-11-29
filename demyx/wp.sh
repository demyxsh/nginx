#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

# Bedrock config
if [[ "${WORDPRESS_BEDROCK:-false}" = true && "$WORDPRESS" = true ]]; then
    NGINX_ROOT=/var/www/html/web
    NGINX_BEDROCK="include /demyx/bedrock.conf;"
    sed -i "s|/wp-login.php|/wp/wp-login.php|g" /demyx/common/wpcommon.conf
fi

# Cloudflare check
NGINX_CLOUDFLARE_CHECK="$(curl -m 1 -svo /dev/null "$NGINX_DOMAIN" 2>&1 | grep "Server: cloudflare" || true)"
if [[ -n "$NGINX_CLOUDFLARE_CHECK" ]]; then
    NGINX_REAL_IP="real_ip_header CF-Connecting-IP; set_real_ip_from 0.0.0.0/0;"
else
    NGINX_REAL_IP="real_ip_header X-Forwarded-For; set_real_ip_from 0.0.0.0/0;"
fi

# NGINX FastCGI cache
if [[ "$NGINX_CACHE" = on && "$WORDPRESS" = true || "$NGINX_CACHE" = true && "$WORDPRESS" = true ]]; then
    NGINX_CACHE_HTTP="include /demyx/cache/http.conf;"
    NGINX_CACHE_SERVER="include /demyx/cache/server.conf;"
    NGINX_CACHE_LOCATION="include /demyx/cache/location.conf;"
fi

# NGINX rate limiting
if [[ "$NGINX_RATE_LIMIT" = on || "$NGINX_RATE_LIMIT" = true ]]; then
    NGINX_RATE_LIMIT_CONNECTION="limit_conn addr 5;"
    NGINX_RATE_LIMIT_LOCATION="limit_req zone=one burst=5 nodelay;"
fi

# NGINX xmlrpc.php
if [[ "$NGINX_XMLRPC" = on && "$WORDPRESS" = true || "$NGINX_XMLRPC" = true && "$WORDPRESS" = true ]]; then
    mv /demyx/common/xmlrpc.conf /demyx/common/xmlrpc.on
fi

# NGINX Basic auth
if [[ "${WORDPRESS_NGINX_BASIC_AUTH:-false}" = on && "$WORDPRESS" = true || "${WORDPRESS_NGINX_BASIC_AUTH:-false}" = true && "$WORDPRESS" = true ]]; then
    echo "$WORDPRESS_NGINX_BASIC_AUTH" > /demyx/.htpasswd
    sed -i "s|#auth_basic|auth_basic|g" /demyx/common/wpcommon.conf
fi

echo "# Demyx
# https://demyx.sh
#
load_module /etc/nginx/modules/ngx_http_cache_purge_module.so;
load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;

error_log stderr notice;
error_log ${NGINX_DOMAIN:-demyx}.error.log;
pid /demyx/nginx.pid;

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
  log_format  main  '\$remote_addr - [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';

  sendfile on;
  sendfile_max_chunk 512k;

  include    /etc/nginx/mime.types;
  include    /etc/nginx/fastcgi.conf;

  default_type application/octet-stream;

  access_log stdout;
  access_log ${NGINX_DOMAIN:-demyx}.access.log main;
  
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
  
  client_max_body_size ${NGINX_UPLOAD_LIMIT:-128M};
  client_body_timeout 10;
  client_body_temp_path /tmp/nginx-client 1 2;
  fastcgi_temp_path /tmp/nginx-fastcgi 1 2;
  proxy_temp_path /tmp/nginx-proxy;
  uwsgi_temp_path /tmp/nginx-uwsgi;
  scgi_temp_path /tmp/nginx-scgi;
  fastcgi_read_timeout 120s;

  resolver 1.1.1.1 1.0.0.1 valid=300s;
  resolver_timeout 10;

  limit_req_status 503;
  limit_req_zone \$request_uri zone=one:10m rate=1r/s;
  limit_conn_zone \$binary_remote_addr zone=addr:10m;
  
  gzip off;

  upstream php {
    server ${WORDPRESS_CONTAINER:-wp}:9000;
  }

  add_header X-Powered-By \"Demyx\";
  add_header X-Frame-Options \"SAMEORIGIN\";
  add_header X-XSS-Protection  \"1; mode=block\";
  add_header X-Content-Type-Options \"nosniff\";
  add_header Referrer-Policy \"strict-origin-when-cross-origin\";
  add_header X-Download-Options \"noopen\";
  add_header Feature-Policy \"geolocation 'self'; midi 'self'; sync-xhr 'self'; microphone 'self'; camera 'self'; magnetometer 'self'; gyroscope 'self'; speaker 'self'; fullscreen 'self'; payment 'self'; usb 'self'\";

  ${NGINX_CACHE_HTTP:-#include /demyx/cache/http.conf;}

  server {
    listen 80;
    root ${NGINX_ROOT:-/var/www/html};
    index index.php index.html index.htm;
    access_log stdout;
    access_log ${NGINX_DOMAIN:-demyx}.access.log main;
    error_log stderr notice;
    error_log ${NGINX_DOMAIN:-demyx}.error.log;

    ${NGINX_REAL_IP:-}

    disable_symlinks off;

    ${NGINX_CACHE_SERVER:-#include /demyx/cache/server.conf;}

    location / {
      try_files \$uri \$uri/ /index.php?\$args;
      ${NGINX_RATE_LIMIT_CONNECTION:-#limit_conn addr 5;}
      ${NGINX_BEDROCK:-}
    }

    location ~ [^/]\.php(/|\$) {
      fastcgi_split_path_info ^(.+?\.php)(/.*)\$;
      if (!-f \$document_root\$fastcgi_script_name) {
        return 404;
      }
      fastcgi_pass php;
      fastcgi_index index.php;
      fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
      include /etc/nginx/fastcgi_params;
      ${NGINX_RATE_LIMIT_LOCATION:-#limit_req zone=one burst=5 nodelay;}
      ${NGINX_CACHE_LOCATION:-#include /demyx/cache/location.conf;}
    }

    include /demyx/common/*.conf;
  }
}" > /demyx/wp.conf