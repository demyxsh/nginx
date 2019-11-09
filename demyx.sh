#!/bin/bash
# Demyx
# https://demyx.sh

NGINX_CONFIG=/demyx/nginx.conf
[[ "$WORDPRESS" = true ]] && NGINX_CONFIG=/demyx/wp.conf
    
# Domain replacement
if [[ -n "$NGINX_DOMAIN" && "$WORDPRESS" = true ]]; then
    sed -i "s|/var/log/demyx/demyx|/var/log/demyx/$NGINX_DOMAIN|g" "$NGINX_CONFIG"
fi

# WordPress container name
if [[ -n "$WORDPRESS_CONTAINER" ]]; then
    sed -i "s|wp:9000|${WORDPRESS_CONTAINER}:9000|g" "$NGINX_CONFIG"
fi

# Cloudflare check
NGINX_CLOUDFLARE_CHECK="$(curl -m 1 -svo /dev/null "$NGINX_DOMAIN" 2>&1 | grep "Server: cloudflare" || true)"
if [[ -n "$NGINX_CLOUDFLARE_CHECK" ]]; then
    sed -i "s|#CF|real_ip_header CF-Connecting-IP; set_real_ip_from 0.0.0.0/0;|g" "$NGINX_CONFIG"
else
    sed -i "s|#CF|real_ip_header X-Forwarded-For; set_real_ip_from 0.0.0.0/0;|g" "$NGINX_CONFIG"
fi

# NGINX Upload limit
if [[ -n "$NGINX_UPLOAD_LIMIT" ]]; then
    sed -i "s|client_max_body_size 128M|client_max_body_size $NGINX_UPLOAD_LIMIT|g" "$NGINX_CONFIG"
fi

# NGINX FastCGI cache
if [[ "$NGINX_CACHE" = on && "$WORDPRESS" = true || "$NGINX_CACHE" = true && "$WORDPRESS" = true ]]; then
    sed -i "s|#include /demyx/cache|include /demyx/cache|g" "$NGINX_CONFIG"
fi

# NGINX rate limiting
if [[ "$NGINX_RATE_LIMIT" = on || "$NGINX_RATE_LIMIT" = true ]]; then
    sed -i "s|#limit_req|limit_req|g" "$NGINX_CONFIG"
    sed -i "s|#limit_conn|limit_conn|g" "$NGINX_CONFIG"
fi

# NGINX xmlrpc.php
if [[ "$NGINX_XMLRPC" = on && "$WORDPRESS" = true || "$NGINX_XMLRPC" = true && "$WORDPRESS" = true ]]; then
    mv /demyx/common/xmlrpc.conf /demyx/common/xmlrpc.on
fi

# NGINX Basic auth
if [[ "$WORDPRESS_NGINX_BASIC_AUTH" = on && "$WORDPRESS" = true || "$WORDPRESS_NGINX_BASIC_AUTH" = true && "$WORDPRESS" = true ]]; then
    echo "$WORDPRESS_NGINX_BASIC_AUTH" > /.htpasswd
    sed -i "s|#auth_basic|auth_basic|g" /demyx/common/wpcommon.conf
fi

nginx -c "$NGINX_CONFIG" -g 'daemon off;'
