#!/bin/sh
# Demyx
# https://demyx.sh
set -euo pipefail

nginx -c "$NGINX_CONFIG"/nginx.conf -s reload
