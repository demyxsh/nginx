FROM nginx:mainline-alpine3.18

LABEL sh.demyx.image                    demyx/nginx
LABEL sh.demyx.maintainer               Demyx <info@demyx.sh>
LABEL sh.demyx.url                      https://demyx.sh
LABEL sh.demyx.github                   https://github.com/demyxsh
LABEL sh.demyx.registry                 https://hub.docker.com/u/demyx

# Set default variables
ENV DEMYX                               /demyx
ENV DEMYX_BASIC_AUTH                    false
ENV DEMYX_BASIC_AUTH_HTPASSWD           false
ENV DEMYX_BEDROCK                       false
ENV DEMYX_CACHE                         false
ENV DEMYX_CACHE_TYPE                    default
ENV DEMYX_CONFIG                        /etc/demyx
ENV DEMYX_DOMAIN                        localhost
ENV DEMYX_LOG                           /var/log/demyx
ENV DEMYX_RATE_LIMIT                    false
ENV DEMYX_UPLOAD_LIMIT                  256M
ENV DEMYX_WHITELIST                     false
ENV DEMYX_WHITELIST_IP                  false
ENV DEMYX_WHITELIST_TYPE                false
ENV DEMYX_WORDPRESS                     false
ENV DEMYX_WORDPRESS_CONTAINER           wp
ENV DEMYX_WORDPRESS_CONTAINER_PORT      9000
ENV DEMYX_XMLRPC                        false
ENV TZ                                  America/Los_Angeles

# Packages
RUN set -ex; \
    apk --update --no-cache add bash curl sudo

# Configure Demyx
RUN set -ex; \
    # Create demyx user
    addgroup -g 1000 -S demyx; \
    adduser -u 1000 -D -S -G demyx demyx; \
    \
    # Create demyx directories
    install -d -m 0755 -o demyx -g demyx "$DEMYX"; \
    install -d -m 0755 -o demyx -g demyx "$DEMYX_CONFIG"; \
    install -d -m 0755 -o demyx -g demyx "$DEMYX_LOG"; \
    \
    # Update .bashrc
    echo 'PS1="$(whoami)@\h:\w \$ "' > /home/demyx/.bashrc; \
    echo 'PS1="$(whoami)@\h:\w \$ "' > /root/.bashrc

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
    gnupg \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    git \
    \
    && mkdir -p /usr/src \
    && git clone https://github.com/nginx-modules/ngx_cache_purge.git /usr/src/ngx_cache_purge \
    && git clone https://github.com/openresty/headers-more-nginx-module.git /usr/src/headers-more-nginx-module

RUN set -ex ;\
    export NGINX_VERSION="$(nginx -v 2>&1 | awk -F '[/]' '{print $2}')" \
    && wget https://nginx.org/download/nginx-"$NGINX_VERSION".tar.gz -qO /usr/src/nginx.tar.gz \
    && tar -xzf /usr/src/nginx.tar.gz -C /usr/src \
    && rm /usr/src/nginx.tar.gz \
    && cd /usr/src/nginx-"$NGINX_VERSION" \
    && ./configure --with-compat --add-dynamic-module=/usr/src/ngx_cache_purge \
    && make modules \
    && cp objs/ngx_http_cache_purge_module.so /usr/lib/nginx/modules \
    && make clean \
    && ./configure --with-compat --add-dynamic-module=/usr/src/headers-more-nginx-module \
    && make modules \
    && cp objs/ngx_http_headers_more_filter_module.so /usr/lib/nginx/modules \
    && rm -rf /usr/src/nginx-"$NGINX_VERSION" /usr/src/ngx_cache_purge /usr/src/headers-more-nginx-module \
    && apk del .build-deps
#
# END BUILD CUSTOM MODULES
#

#
#   Rocket-Nginx support for WP Rocket - https://github.com/SatelliteWP/rocket-nginx
#
RUN set -ex; \
    apk add --no-cache --virtual .build-deps git php81; \
    \
    su -c "mkdir -p ${DEMYX_CONFIG}/custom/nginx; \
        cd ${DEMYX_CONFIG}/custom/nginx; \
        git clone https://github.com/SatelliteWP/rocket-nginx.git; \
        cd rocket-nginx; \
        cp rocket-nginx.ini.disabled rocket-nginx.ini; \
        php81 rocket-parser.php; \
        cd ..; \
        tar -czf ${DEMYX_CONFIG}/rocket-nginx.tgz rocket-nginx" -s /bin/bash demyx; \
    \
    apk del .build-deps; \
    rm -rf /var/cache/apk/*; \
    rm -rf "$DEMYX_CONFIG"/custom/nginx

# Configure sudo
RUN set -ex; \
    \
    echo "demyx ALL=(ALL) NOPASSWD:SETENV: /usr/local/bin/demyx-entrypoint, /usr/local/bin/demyx-reload" > /etc/sudoers.d/demyx; \
    \
    touch /etc/nginx/stdout; \
    \
    chown demyx:demyx /etc/nginx/stdout

# Imports
COPY --chown=root:root bin /usr/local/bin
COPY --chown=demyx:demyx config "$DEMYX_CONFIG"

# Finalize
RUN set -ex; \
    # Create copy of /etc/demyx in an archive
    tar -czf /etc/demyx.tgz -C "$DEMYX_CONFIG" .; \
    \
    # Set ownership
    chown -R root:root /usr/local/bin

EXPOSE 80

WORKDIR "$DEMYX"

USER demyx

ENTRYPOINT ["sudo", "-E", "demyx-entrypoint"]
