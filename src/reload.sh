#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

/usr/sbin/nginx -c "$DEMYX_CONFIG"/nginx.conf -s reload
