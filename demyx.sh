#!/bin/sh
# Demyx
# https://demyx.sh
set -euo pipefail

# Compatibility with old paths
[[ -d /var/www/html ]] && NGINX_ROOT=/var/www/html

# Generate config
if [[ "$WORDPRESS" = true ]]; then
    [[ ! -f "$NGINX_CONFIG"/nginx.conf ]] && demyx-wp
else
    [[ ! -f "$NGINX_CONFIG"/nginx.conf ]] && demyx-default
fi

sudo nginx -c "$NGINX_CONFIG"/nginx.conf -g 'daemon off;'
