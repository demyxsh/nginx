#!/usr/bin/dumb-init /bin/sh
# Demyx
# https://demyx.sh
set -euo pipefail

# Set WORDPRESS variable to false by default
WORDPRESS="${WORDPRESS:-false}"

# Generate config
if [[ "$WORDPRESS" = true ]]; then
    [[ ! -f "$NGINX_CONFIG"/nginx.conf ]] && demyx-wp
else
    [[ ! -f "$NGINX_CONFIG"/nginx.conf ]] && demyx-default
fi

sudo nginx -c "$NGINX_CONFIG"/nginx.conf -g 'daemon off;'
