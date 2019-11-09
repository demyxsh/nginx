#!/bin/bash
# Demyx
# https://demyx.sh

# WordPress mode
if [[ "$WORDPRESS" = true ]]; then
    # Domain replacement
    if [[ -n "$WORDPRESS_DOMAIN" ]]; then
        sed -i "s|/var/log/demyx/demyx|/var/log/demyx/$WORDPRESS_DOMAIN|g" /demyx/wp.conf
    fi

    # WordPress container name
    if [[ -n "$WORDPRESS_CONTAINER" ]]; then
        sed -i "s|wp:9000|${WORDPRESS_CONTAINER}:9000|g" /demyx/wp.conf
    fi

    # Cloudflare check
    WORDPRESS_CLOUDFLARE_CHECK="$(curl -m 1 -svo /dev/null "$WORDPRESS_DOMAIN" 2>&1 | grep "Server: cloudflare" || true)"
    if [[ -n "$WORDPRESS_CLOUDFLARE_CHECK" ]]; then
        sed -i "s|#CF|real_ip_header CF-Connecting-IP; set_real_ip_from 0.0.0.0/0;|g" /demyx/wp.conf
    else
        sed -i "s|#CF|real_ip_header X-Forwarded-For; set_real_ip_from 0.0.0.0/0;|g" /demyx/wp.conf
    fi

    # NGINX Upload limit
    if [[ -n "$WORDPRESS_UPLOAD_LIMIT" ]]; then
        sed -i "s|client_max_body_size 128M|client_max_body_size $WORDPRESS_UPLOAD_LIMIT|g" /demyx/wp.conf
    fi

    # NGINX FastCGI cache
    if [[ "$WORDPRESS_NGINX_CACHE" = on || "$WORDPRESS_NGINX_CACHE" = true ]]; then
        sed -i "s|#include /demyx/cache|include /demyx/cache|g" /demyx/wp.conf
    fi

    # NGINX rate limiting
    if [[ "$WORDPRESS_NGINX_RATE_LIMIT" = on || "$WORDPRESS_NGINX_RATE_LIMIT" = true ]]; then
        sed -i "s|#limit_req|limit_req|g" /demyx/wp.conf
        sed -i "s|#limit_conn|limit_conn|g" /demyx/wp.conf
    fi

    # NGINX xmlrpc.php
    if [[ "$WORDPRESS_NGINX_XMLRPC" = on || "$WORDPRESS_NGINX_XMLRPC" = true ]]; then
        mv /demyx/common/xmlrpc.conf /demyx/common/xmlrpc.on
    fi

    # NGINX Basic auth
    if [[ "$WORDPRESS_NGINX_BASIC_AUTH" = on || "$WORDPRESS_NGINX_BASIC_AUTH" = true ]]; then
        echo "$WORDPRESS_NGINX_BASIC_AUTH" > /.htpasswd
        sed -i "s|#auth_basic|auth_basic|g" /demyx/common/wpcommon.conf
    fi

    nginx -c /demyx/wp.conf -g 'daemon off;'
else
    nginx -g 'daemon off;'
fi
