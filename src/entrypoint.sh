#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

# Support for old variables
[[ -n "${WORDPRESS:-}" ]] && DEMYX_WORDPRESS="$WORDPRESS"

# Generate demyx config
[[ ! -d "$DEMYX_CONFIG"/nginx ]] && /usr/bin/tar -xzf /etc/demyx.tgz -C "$DEMYX_CONFIG"

# Generate wp config
if [[ "$DEMYX_WORDPRESS" = true ]]; then
    [[ ! -f "$DEMYX_CONFIG"/nginx.conf ]] && /usr/local/bin/demyx-wp
else
    [[ ! -f "$DEMYX_CONFIG"/nginx.conf ]] && /usr/local/bin/demyx-default
fi

# Run in the background for now
/usr/sbin/nginx -c "$DEMYX_CONFIG"/nginx.conf

# Set ownerships to demyx
/bin/chown -R demyx:demyx "$DEMYX"
/bin/chown -R demyx:demyx "$DEMYX_CONFIG"
/bin/chown -R demyx:demyx "$DEMYX_LOG"

# Restart nginx in the background
/usr/bin/pkill nginx && /usr/sbin/nginx -c "$DEMYX_CONFIG"/nginx.conf -g 'daemon off;'
