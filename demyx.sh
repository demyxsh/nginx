#!/bin/bash
# Demyx
# https://demyx.sh

# Generate config
if [[ "$WORDPRESS" = true ]]; then
    NGINX_CONFIG=/demyx/wp.conf
    demyx-wp
else
    NGINX_CONFIG=/demyx/default.conf
    demyx-default
fi

sudo nginx -c "$NGINX_CONFIG" -g 'daemon off;'
