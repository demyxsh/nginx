#!/bin/bash

# WordPress mode
if [[ "$WORDPRESS" = true ]]; then
	cp /usr/src/wp.conf /etc/nginx/nginx.conf 

	# Domain replacement
	if [[ -n "$WORDPRESS_DOMAIN" ]]; then
		sed -i "s|demyx.|$WORDPRESS_DOMAIN.|g" /etc/nginx/nginx.conf
		sed -i "s|demyx.error|$WORDPRESS_DOMAIN.error|g" /etc/php7/php-fpm.d/www.conf
	fi

	# Container replacement
	if [[ -n "$WORDPRESS_SERVICE" ]]; then
		sed -i "s|container|$WORDPRESS_SERVICE|g" /etc/nginx/nginx.conf
	fi

	# Cloudflare check
	DEMYX_CLOUDFLARE_CHECK="$(curl -svo /dev/null "$WORDPRESS_DOMAIN" 2>&1 | grep "Server: cloudflare" || true)"
	if [[ -n "$DEMYX_CLOUDFLARE_CHECK" ]]; then
		sed -i "s|#CF|real_ip_header CF-Connecting-IP; set_real_ip_from 0.0.0.0/0;|g" /etc/nginx/nginx.conf
	else
		sed -i "s|#CF|real_ip_header X-Forwarded-For; set_real_ip_from 0.0.0.0/0;|g" /etc/nginx/nginx.conf
	fi

	# NGINX Upload limit
	if [[ -n "$DEMYX_UPLOAD_LIMIT" ]]; then
		sed -i "s|client_max_body_size 128M|client_max_body_size $DEMYX_UPLOAD_LIMIT|g" /etc/nginx/nginx.conf
	fi

	# NGINX FastCGI cache
	if [[ "$DEMYX_NGINX_CACHE" = true ]]; then
		sed -i "s|#include /etc/nginx/cache|include /etc/nginx/cache|g" /etc/nginx/nginx.conf
	fi

	# NGINX rate limiting
	if [[ "$DEMYX_RATE_LIMIT" = true ]]; then
		sed -i "s|#limit_req|limit_req|g" /etc/nginx/nginx.conf
	fi

	# Basic auth
	if [[ -n "$DEMYX_BASIC_AUTH" ]]; then
		echo "$DEMYX_BASIC_AUTH" > /.htpasswd
		sed -i "s|#auth_basic|auth_basic|g" /etc/nginx/nginx.conf
	fi
fi

nginx -g 'daemon off;'
