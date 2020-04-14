#!/bin/sh
# Demyx
# https://demyx.sh
set -euo pipefail

sudo nginx -c "$NGINX_CONFIG"/nginx.conf -s reload
