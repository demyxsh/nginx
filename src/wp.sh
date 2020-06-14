#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

# Bedrock config
if [[ "${WORDPRESS_BEDROCK:-false}" = true && "$WORDPRESS" = true ]]; then
    NGINX_ROOT="$NGINX_ROOT"/web
    NGINX_BEDROCK="include "$NGINX_CONFIG"/nginx/bedrock.conf;"
    sed -i "s|/wp-login.php|/wp/wp-login.php|g" "$NGINX_CONFIG"/common/wpcommon.conf
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
    NGINX_CACHE_HTTP="include "$NGINX_CONFIG"/cache/http.conf;"
    NGINX_CACHE_SERVER="include "$NGINX_CONFIG"/cache/server.conf;"
    NGINX_CACHE_LOCATION="include "$NGINX_CONFIG"/cache/location.conf;"
fi

# NGINX rate limiting
if [[ "$NGINX_RATE_LIMIT" = on || "$NGINX_RATE_LIMIT" = true ]]; then
    NGINX_RATE_LIMIT_CONNECTION="limit_conn addr 5;"
    NGINX_RATE_LIMIT_LOCATION="limit_req zone=ip burst=5 nodelay;
    limit_req zone=server burst=10;"
fi

# NGINX xmlrpc.php
if [[ "$NGINX_XMLRPC" = on && "$WORDPRESS" = true || "$NGINX_XMLRPC" = true && "$WORDPRESS" = true ]]; then
    mv "$NGINX_CONFIG"/common/xmlrpc.conf "$NGINX_CONFIG"/common/xmlrpc.on
fi

# NGINX Basic auth
NGINX_BASIC_AUTH="${NGINX_BASIC_AUTH:-false}"
if [[ "${NGINX_BASIC_AUTH}" = true && "$WORDPRESS" = true || "${NGINX_BASIC_AUTH}" = true && "$WORDPRESS" = true ]]; then
    echo "$NGINX_BASIC_AUTH_HTPASSWD" > "$NGINX_CONFIG"/.htpasswd
    sed -i "s|#include ${NGINX_CONFIG}/nginx/auth.conf;|include ${NGINX_CONFIG}/nginx/auth.conf;|g" "$NGINX_CONFIG"/common/wpcommon.conf
fi

echo "# Demyx
# https://demyx.sh
#
load_module /etc/nginx/modules/ngx_http_cache_purge_module.so;
load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;

error_log stderr notice;
error_log ${NGINX_LOG}/${NGINX_DOMAIN:-demyx}.error.log;
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

  access_log stdout;
  access_log ${NGINX_LOG}/${NGINX_DOMAIN:-demyx}.access.log main;

  sendfile on;
  sendfile_max_chunk 512k;

  tcp_nopush on;
  tcp_nodelay on;

  keepalive_timeout 8;
  keepalive_requests 500;
  keepalive_disable msie6;

  lingering_time 20s;
  lingering_timeout 5s;

  server_tokens off;
  reset_timedout_connection on;
  add_header X-Powered-By \"Demyx - https://demyx.sh\";
  add_header X-FastCGI-Cache \$upstream_cache_status;

  limit_req_status 503;
  limit_req_zone \$request_uri zone=common:10m rate=1r/s;
  limit_req_zone \$binary_remote_addr zone=ip:10m rate=1r/s;
  limit_req_zone \$server_name zone=server:10m rate=10r/s;
  limit_conn_zone \$binary_remote_addr zone=addr:10m;

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

  # Common security headers
  more_set_headers \"X-Frame-Options : SAMEORIGIN\";
  more_set_headers \"X-Xss-Protection : 1; mode=block\";
  more_set_headers \"X-Content-Type-Options : nosniff\";
  more_set_headers \"Referrer-Policy : strict-origin-when-cross-origin\";
  more_set_headers \"X-Download-Options : noopen\";

  include ${NGINX_CONFIG}/nginx/mime.types;
  default_type application/octet-stream;

  gzip off;

  upstream php {
    server ${WORDPRESS_CONTAINER:-wp}:${WORDPRESS_CONTAINER_PORT:-9000};
  }

  map \$http_accept \$webp_suffix {
    default \"\";
    \"~*webp\" \".webp\";
  }

  ${NGINX_CACHE_HTTP:-}

  server {
    listen 80;
    root ${NGINX_ROOT};
    index index.php index.html index.htm;
    access_log stdout;
    access_log ${NGINX_LOG}/${NGINX_DOMAIN:-demyx}.access.log main;
    error_log stderr notice;
    error_log ${NGINX_LOG}/${NGINX_DOMAIN:-demyx}.error.log;
    disable_symlinks off;

    ${NGINX_REAL_IP:-}
    ${NGINX_CACHE_SERVER:-}
    ${NGINX_RATE_LIMIT_CONNECTION:-}
    ${NGINX_RATE_LIMIT_LOCATION:-}

    location / {
      try_files \$uri \$uri/ /index.php?\$args;
      ${NGINX_BEDROCK:-}
      #include ${NGINX_CONFIG}/nginx/whitelist.conf;
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
      ${NGINX_CACHE_LOCATION:-}
      #include ${NGINX_CONFIG}/nginx/whitelist.conf;
    }

    include ${NGINX_CONFIG}/common/*.conf;
  }
}" > "$NGINX_CONFIG"/nginx.conf

# NGINX IP whitelist
if [[ "$NGINX_WHITELIST" = true && "$WORDPRESS" = true ]]; then
    NGINX_WHITELIST_IPS="$(echo "$NGINX_WHITELIST_IP" | sed "s|,| |g")"
    for i in $NGINX_WHITELIST_IPS
    do
        echo "allow $i;" >> "$NGINX_CONFIG"/nginx/whitelist.conf
    done
    echo "deny all;" >> "$NGINX_CONFIG"/nginx/whitelist.conf
    
    if [[ "$NGINX_WHITELIST_TYPE" = login ]]; then
        sed -i "s|#include ${NGINX_CONFIG}/nginx/whitelist.conf;|include ${NGINX_CONFIG}/nginx/whitelist.conf;|g" "$NGINX_CONFIG"/common/wpcommon.conf
    elif [[ "$NGINX_WHITELIST_TYPE" = all ]]; then
        sed -i "s|#include ${NGINX_CONFIG}/nginx/whitelist.conf;|include ${NGINX_CONFIG}/nginx/whitelist.conf;|g" "$NGINX_CONFIG"/nginx.conf
        sed -i "s|#include ${NGINX_CONFIG}/nginx/whitelist.conf;|include ${NGINX_CONFIG}/nginx/whitelist.conf;|g" "$NGINX_CONFIG"/common/wpcommon.conf
    fi
fi
