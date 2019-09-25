#!/bin/bash
# Demyx
# https://demyx.sh

# WordPress mode
if [[ "$WORDPRESS" = true ]]; then
	cp /usr/src/wp.conf /etc/nginx/nginx.conf 

	# Domain replacement
	if [[ -n "$NGINX_DOMAIN" ]]; then
		sed -i "s|/var/log/demyx/demyx|/var/log/demyx/$NGINX_DOMAIN|g" /etc/nginx/nginx.conf
	fi

	# Container replacement
	if [[ -n "$WORDPRESS_SERVICE" ]]; then
		sed -i "s|container|$WORDPRESS_SERVICE|g" /etc/nginx/nginx.conf
	fi

	# Cloudflare check
	NGINX_CLOUDFLARE_CHECK="$(curl -svo /dev/null "$NGINX_DOMAIN" 2>&1 | grep "Server: cloudflare" || true)"
	if [[ -n "$NGINX_CLOUDFLARE_CHECK" ]]; then
		sed -i "s|#CF|real_ip_header CF-Connecting-IP; set_real_ip_from 0.0.0.0/0;|g" /etc/nginx/nginx.conf
	else
		sed -i "s|#CF|real_ip_header X-Forwarded-For; set_real_ip_from 0.0.0.0/0;|g" /etc/nginx/nginx.conf
	fi

	# NGINX Upload limit
	if [[ -n "$NGINX_UPLOAD_LIMIT" ]]; then
		sed -i "s|client_max_body_size 128M|client_max_body_size $NGINX_UPLOAD_LIMIT|g" /etc/nginx/nginx.conf
	fi

	# NGINX FastCGI cache
	if [[ "$NGINX_CACHE" = on ]]; then
		sed -i "s|#include /etc/nginx/cache|include /etc/nginx/cache|g" /etc/nginx/nginx.conf
	fi

	# NGINX rate limiting
	if [[ "$NGINX_RATE_LIMIT" = on ]]; then
		sed -i "s|#limit_req|limit_req|g" /etc/nginx/nginx.conf
	fi

	# Basic auth
	if [[ -n "$NGINX_BASIC_AUTH" ]]; then
		echo "$NGINX_BASIC_AUTH" > /.htpasswd
		sed -i "s|#auth_basic|auth_basic|g" /etc/nginx/nginx.conf
	fi
fi

nginx -g 'daemon off;'
