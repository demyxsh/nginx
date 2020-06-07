#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

# Generate demyx config
[[ ! -d "$NGINX_CONFIG"/nginx ]] && tar -xzf /etc/demyx.tgz -C "$NGINX_CONFIG"

# Generate wp config
if [[ "$WORDPRESS" = true ]]; then
    [[ ! -f "$NGINX_CONFIG"/nginx.conf ]] && demyx-wp
else
    [[ ! -f "$NGINX_CONFIG"/nginx.conf ]] && demyx-default
fi

# Run in the background for now
nginx -c "$NGINX_CONFIG"/nginx.conf

# Set ownerships to demyx
chown -R demyx:demyx "$NGINX_ROOT"
chown -R demyx:demyx "$NGINX_CONFIG"
chown -R demyx:demyx "$NGINX_LOG"

# Restart nginx in the background
pkill nginx && nginx -c "$NGINX_CONFIG"/nginx.conf -g 'daemon off;'
