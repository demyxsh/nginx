FROM alpine

LABEL sh.demyx.image demyx/nginx
LABEL sh.demyx.maintainer Demyx <info@demyx.sh>
LABEL sh.demyx.url https://demyx.sh
LABEL sh.demyx.github https://github.com/demyxco
LABEL sh.demyx.registry https://hub.docker.com/u/demyx

# Set default variables
ENV NGINX_ROOT=/demyx
ENV NGINX_CONFIG=/etc/demyx
ENV NGINX_LOG=/var/log/demyx
ENV TZ America/Los_Angeles

# Configure Demyx
RUN set -ex; \
    addgroup -g 1000 -S demyx; \
    adduser -u 1000 -D -S -G demyx demyx; \
    \
    install -d -m 0755 -o demyx -g demyx "$NGINX_ROOT"; \
    install -d -m 0755 -o demyx -g demyx "$NGINX_CONFIG"; \
    install -d -m 0755 -o demyx -g demyx "$NGINX_LOG"

#    
# BUILD CUSTOM MODULES
#
RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    gnupg1 \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    git \
    \
    && export NGINX_VERSION="$(wget -qO- https://raw.githubusercontent.com/nginxinc/docker-nginx/master/mainline/alpine/Dockerfile | grep 'ENV NGINX_VERSION' | cut -c 19-)" \
    && mkdir -p /usr/src \
    && git clone https://github.com/FRiCKLE/ngx_cache_purge.git /usr/src/ngx_cache_purge \
    && git clone https://github.com/openresty/headers-more-nginx-module.git /usr/src/headers-more-nginx-module \
    && wget https://nginx.org/download/nginx-"$NGINX_VERSION".tar.gz -qO /usr/src/nginx.tar.gz \
    && tar -xzf /usr/src/nginx.tar.gz -C /usr/src \
    && rm /usr/src/nginx.tar.gz \
    && sed -i "s/HTTP_MODULES/#HTTP_MODULES/g" /usr/src/ngx_cache_purge/config \
    && sed -i "s/NGX_ADDON_SRCS/#NGX_ADDON_SRCS/g" /usr/src/ngx_cache_purge/config \
    && sed -i "s|ngx_addon_name=ngx_http_cache_purge_module|ngx_addon_name=ngx_http_cache_purge_module; if test -n \"\$ngx_module_link\"; then ngx_module_type=HTTP; ngx_module_name=ngx_http_cache_purge_module; ngx_module_srcs=\"\$ngx_addon_dir/ngx_cache_purge_module.c\"; . auto/module; else HTTP_MODULES=\"\$HTTP_MODULES ngx_http_cache_purge_module\"; NGX_ADDON_SRCS=\"\$NGX_ADDON_SRCS \$ngx_addon_dir/ngx_cache_purge_module.c\"; fi|g" /usr/src/ngx_cache_purge/config \
    && sed -i "s|ngx_addon_name=ngx_http_headers_more_filter_module|ngx_addon_name=ngx_http_headers_more_filter_module; if test -n \"\$ngx_module_link\"; then ngx_module_type=HTTP; ngx_module_name=ngx_http_headers_more_filter_module; ngx_module_srcs=\"\$ngx_addon_dir/ngx_http_headers_more_filter_module.c\"; . auto/module; else HTTP_MODULES=\"\$HTTP_MODULES ngx_http_headers_more_filter_module\"; NGX_ADDON_SRCS=\"\$NGX_ADDON_SRCS \$ngx_addon_dir/ngx_http_headers_more_filter_module.c\"; fi|g" /usr/src/headers-more-nginx-module/config \
    && cd /usr/src/nginx-"$NGINX_VERSION" \
    && ./configure --with-compat --add-dynamic-module=/usr/src/ngx_cache_purge \
    && make modules \
    && cp objs/ngx_http_cache_purge_module.so /etc/nginx/modules \
    && make clean \
    && ./configure --with-compat --add-dynamic-module=/usr/src/headers-more-nginx-module \
    && make modules \
    && cp objs/ngx_http_headers_more_filter_module.so /etc/nginx/modules \
    && rm -rf /usr/src/nginx-"$NGINX_VERSION" /usr/src/ngx_cache_purge /usr/src/headers-more-nginx-module \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*
#    
# END BUILD CUSTOM MODULES
#

# Copy files
COPY --chown=demyx:demyx demyx "$NGINX_CONFIG"
COPY demyx.sh /usr/local/bin/demyx

# Error pages - https://github.com/alexphelps/server-error-pages
RUN set -x; \
    apk add --no-cache --virtual .error-deps git; \
    \
    git clone https://github.com/alexphelps/server-error-pages.git "$NGINX_CONFIG"/error; \
    chown -R demyx:demyx "$NGINX_CONFIG"/error; \
    \
    apk del .error-deps; \
    rm -rf /var/cache/apk/*

# Install packages and run customizations
RUN set -ex; \
    apk add --update --no-cache dumb-init sudo; \
    \
    echo "demyx ALL=(ALL) NOPASSWD:/usr/sbin/nginx" > /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="WORDPRESS"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="WORDPRESS_BEDROCK"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="NGINX_DOMAIN"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="NGINX_UPLOAD_LIMIT"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="WORDPRESS_CONTAINER"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="WORDPRESS_CONTAINER_PORT"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="NGINX_CACHE"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="NGINX_RATE_LIMIT"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="NGINX_XMLRPC"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="NGINX_BASIC_AUTH"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="NGINX_BASIC_AUTH_HTPASSWD"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="TZ"' >> /etc/sudoers.d/demyx; \
    \
    touch /etc/nginx/stdout; \
    \
    chown demyx:demyx /etc/nginx/stdout; \
    \
    mv "$NGINX_CONFIG"/default.sh /usr/local/bin/demyx-default; \
    mv "$NGINX_CONFIG"/reload.sh /usr/local/bin/demyx-reload; \
    mv "$NGINX_CONFIG"/wp.sh /usr/local/bin/demyx-wp; \
    \
    chmod +x /usr/local/bin/demyx-default; \
    chmod +x /usr/local/bin/demyx-reload; \
    chmod +x /usr/local/bin/demyx-wp; \
    chmod +x /usr/local/bin/demyx

EXPOSE 80

WORKDIR "$NGINX_ROOT"

USER demyx

ENTRYPOINT ["dumb-init", "demyx"]
