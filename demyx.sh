#!/bin/sh
# Demyx
# https://demyx.sh
set -euo pipefail

# Compatibility with old paths
[[ -d /var/www/html ]] && NGINX_ROOT=/var/www/html

# Generate config
if [[ "$WORDPRESS" = true ]]; then
    NGINX_FILE="$NGINX_CONFIG"/wp.conf
    [[ ! -f "$NGINX_CONFIG"/wp.conf ]] && demyx-wp
else
    NGINX_FILE="$NGINX_CONFIG"/default.conf
    [[ ! -f "$NGINX_CONFIG"/default.conf ]] && demyx-default
fi

sudo nginx -c "$NGINX_FILE" -g 'daemon off;'
