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

# Run in the background for now
nginx -c "$NGINX_CONFIG"/nginx.conf

# Set logs to demyx user
chown -R demyx:demyx "$NGINX_LOG"

# Restart nginx in the background
pkill nginx && nginx -c "$NGINX_CONFIG"/nginx.conf -g 'daemon off;'
