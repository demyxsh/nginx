FROM alpine

LABEL sh.demyx.image                    demyx/nginx
LABEL sh.demyx.maintainer               Demyx <info@demyx.sh>
LABEL sh.demyx.url                      https://demyx.sh
LABEL sh.demyx.github                   https://github.com/demyxco
LABEL sh.demyx.registry                 https://hub.docker.com/u/demyx

# Set default variables
ENV DEMYX                               /demyx
ENV DEMYX_BASIC_AUTH                    false
ENV DEMYX_BASIC_AUTH_HTPASSWD           false
ENV DEMYX_BEDROCK                       false
ENV DEMYX_CACHE                         false
ENV DEMYX_CONFIG                        /etc/demyx
ENV DEMYX_DOMAIN                        localhost
ENV DEMYX_LOG                           /var/log/demyx
ENV DEMYX_RATE_LIMIT                    false
ENV DEMYX_UPLOAD_LIMIT                  128M
ENV DEMYX_WHITELIST                     false
ENV DEMYX_WHITELIST_IP                  false
ENV DEMYX_WHITELIST_TYPE                false
ENV DEMYX_WORDPRESS                     false
ENV DEMYX_WORDPRESS_CONTAINER           wp
ENV DEMYX_WORDPRESS_CONTAINER_PORT      9000
ENV DEMYX_XMLRPC                        false
ENV TZ                                  America/Los_Angeles
# Support for old variables
ENV NGINX_ROOT                          "$DEMYX"
ENV NGINX_CONFIG                        "$DEMYX_CONFIG"
ENV NGINX_LOG                           "$DEMYX_LOG"

# Configure Demyx
RUN set -ex; \
    /usr/sbin/addgroup -g 1000 -S demyx; \
    /usr/sbin/adduser -u 1000 -D -S -G demyx demyx; \
    \
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX"; \
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX_CONFIG"; \
    /usr/bin/install -d -m 0755 -o demyx -g demyx "$DEMYX_LOG"

RUN set -x \
# Auto populate these variables from upstream's Dockerfile
    && NGINX_DOCKERFILE="$(/usr/bin/wget -qO- https://raw.githubusercontent.com/nginxinc/docker-nginx/master/mainline/alpine/Dockerfile)" \
    && NGINX_ALPINE="$(/bin/echo "$NGINX_DOCKERFILE" | /bin/grep 'FROM' | /usr/bin/awk -F '[:]' '{print $2}')" \
    && NGINX_VERSION="$(/bin/echo "$NGINX_DOCKERFILE" | /bin/grep 'ENV NGINX_VERSION' | /usr/bin/cut -c 19-)" \
    && NJS_VERSION="$(/bin/echo "$NGINX_DOCKERFILE" | /bin/grep 'ENV NJS_VERSION' | /usr/bin/cut -c 19-)" \
    && PKG_RELEASE="$(/bin/echo "$NGINX_DOCKERFILE" | /bin/grep 'ENV PKG_RELEASE' | /usr/bin/cut -c 19-)" \
    && KEY_SHA512="$(/bin/echo "$NGINX_DOCKERFILE" | /bin/grep 'KEY_SHA512=' | /bin/sed 's|\\||g' | /bin/sed 's|\"||g' | /bin/sed 's|stdin |stdin|g' | /usr/bin/awk -F '[=]' '{print $2}')" \
# create nginx user/group first, to be consistent throughout docker variants
    && /usr/sbin/addgroup -g 101 -S nginx \
    && /usr/sbin/adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apkArch="$(/bin/cat /etc/apk/arch)" \
    && nginxPackages=" \
        nginx=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-xslt=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-geoip=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-image-filter=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION}-r${PKG_RELEASE} \
    " \
    && case "$apkArch" in \
        x86_64) \
# arches officially built by upstream
            set -x \
            && /sbin/apk add --no-cache --virtual .cert-deps \
                openssl \
            && /usr/bin/wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
            && if [ "$(/usr/bin/openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout | openssl sha512 -r)" = "$KEY_SHA512" ]; then \
                /bin/echo "key verification succeeded!"; \
                /bin/mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
            else \
                /bin/echo "key verification failed!"; \
                exit 1; \
            fi \
            && /sbin/apk del .cert-deps \
            && /sbin/apk add -X "https://nginx.org/packages/mainline/alpine/v${NGINX_ALPINE}/main" --no-cache $nginxPackages \
            ;; \
        *) \
# we're on an architecture upstream doesn't officially build for
# let's build binaries from the published packaging sources
            set -x \
            && tempDir="$(/bin/mktemp -d)" \
            && /bin/chown nobody:nobody $tempDir \
            && /sbin/apk add --no-cache --virtual .build-deps \
                gcc \
                libc-dev \
                make \
                openssl-dev \
                pcre-dev \
                zlib-dev \
                linux-headers \
                libxslt-dev \
                gd-dev \
                geoip-dev \
                perl-dev \
                libedit-dev \
                mercurial \
                bash \
                alpine-sdk \
                findutils \
            && /bin/su nobody -s /bin/sh -c " \
                export HOME=${tempDir} \
                && cd ${tempDir} \
                && /usr/bin/hg clone https://hg.nginx.org/pkg-oss \
                && cd pkg-oss \
                && /usr/bin/hg up ${NGINX_VERSION}-${PKG_RELEASE} \
                && cd alpine \
                && /usr/bin/make all \
                && /sbin/apk index -o ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz ${tempDir}/packages/alpine/${apkArch}/*.apk \
                && /usr/bin/abuild-sign -k ${tempDir}/.abuild/abuild-key.rsa ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz \
                " \
            && /bin/cp ${tempDir}/.abuild/abuild-key.rsa.pub /etc/apk/keys/ \
            && /sbin/apk del .build-deps \
            && /sbin/apk add -X ${tempDir}/packages/alpine/ --no-cache $nginxPackages \
            ;; \
    esac \
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then /bin/rm -rf "$tempDir"; fi \
    && if [ -n "/etc/apk/keys/abuild-key.rsa.pub" ]; then /bin/rm -f /etc/apk/keys/abuild-key.rsa.pub; fi \
    && if [ -n "/etc/apk/keys/nginx_signing.rsa.pub" ]; then /bin/rm -f /etc/apk/keys/nginx_signing.rsa.pub; fi \
# Bring in gettext so we can get `envsubst`, then throw
# the rest away. To do this, we need to install `gettext`
# then move `envsubst` out of the way so `gettext` can
# be deleted completely, then move `envsubst` back.
    && /sbin/apk add --no-cache --virtual .gettext gettext \
    && /bin/mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        /usr/bin/scanelf --needed --nobanner /tmp/envsubst \
            | /usr/bin/awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | /usr/bin/sort -u \
            | /usr/bin/xargs -r /sbin/apk info --installed \
            | /usr/bin/sort -u \
    )" \
    && /sbin/apk add --no-cache $runDeps \
    && /sbin/apk del .gettext \
    && /bin/mv /tmp/envsubst /usr/local/bin/ \
# Bring in tzdata so users could set the timezones through the environment
# variables
    && /sbin/apk add --no-cache tzdata \
# forward request and error logs to docker log collector
    && /bin/ln -sf /dev/stdout /var/log/nginx/access.log \
    && /bin/ln -sf /dev/stderr /var/log/nginx/error.log

#    
# BUILD CUSTOM MODULES
#
RUN set -ex; \
    /sbin/apk add --no-cache --virtual .build-deps \
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
    && export NGINX_VERSION="$(/usr/bin/wget -qO- https://raw.githubusercontent.com/nginxinc/docker-nginx/master/mainline/alpine/Dockerfile | /bin/grep 'ENV NGINX_VERSION' | /usr/bin/cut -c 19-)" \
    && /bin/mkdir -p /usr/src \
    && /usr/bin/git clone https://github.com/FRiCKLE/ngx_cache_purge.git /usr/src/ngx_cache_purge \
    && /usr/bin/git clone https://github.com/openresty/headers-more-nginx-module.git /usr/src/headers-more-nginx-module \
    && /usr/bin/wget https://nginx.org/download/nginx-"$NGINX_VERSION".tar.gz -qO /usr/src/nginx.tar.gz \
    && /bin/tar -xzf /usr/src/nginx.tar.gz -C /usr/src \
    && /bin/rm /usr/src/nginx.tar.gz \
    && /bin/sed -i "s/HTTP_MODULES/#HTTP_MODULES/g" /usr/src/ngx_cache_purge/config \
    && /bin/sed -i "s/NGX_ADDON_SRCS/#NGX_ADDON_SRCS/g" /usr/src/ngx_cache_purge/config \
    && /bin/sed -i "s|ngx_addon_name=ngx_http_cache_purge_module|ngx_addon_name=ngx_http_cache_purge_module; if test -n \"\$ngx_module_link\"; then ngx_module_type=HTTP; ngx_module_name=ngx_http_cache_purge_module; ngx_module_srcs=\"\$ngx_addon_dir/ngx_cache_purge_module.c\"; . auto/module; else HTTP_MODULES=\"\$HTTP_MODULES ngx_http_cache_purge_module\"; NGX_ADDON_SRCS=\"\$NGX_ADDON_SRCS \$ngx_addon_dir/ngx_cache_purge_module.c\"; fi|g" /usr/src/ngx_cache_purge/config \
    && /bin/sed -i "s|ngx_addon_name=ngx_http_headers_more_filter_module|ngx_addon_name=ngx_http_headers_more_filter_module; if test -n \"\$ngx_module_link\"; then ngx_module_type=HTTP; ngx_module_name=ngx_http_headers_more_filter_module; ngx_module_srcs=\"\$ngx_addon_dir/ngx_http_headers_more_filter_module.c\"; . auto/module; else HTTP_MODULES=\"\$HTTP_MODULES ngx_http_headers_more_filter_module\"; NGX_ADDON_SRCS=\"\$NGX_ADDON_SRCS \$ngx_addon_dir/ngx_http_headers_more_filter_module.c\"; fi|g" /usr/src/headers-more-nginx-module/config \
    && cd /usr/src/nginx-"$NGINX_VERSION" \
    && ./configure --with-compat --add-dynamic-module=/usr/src/ngx_cache_purge \
    && /usr/bin/make modules \
    && /bin/cp objs/ngx_http_cache_purge_module.so /etc/nginx/modules \
    && /usr/bin/make clean \
    && ./configure --with-compat --add-dynamic-module=/usr/src/headers-more-nginx-module \
    && /usr/bin/make modules \
    && /bin/cp objs/ngx_http_headers_more_filter_module.so /etc/nginx/modules \
    && /bin/rm -rf /usr/src/nginx-"$NGINX_VERSION" /usr/src/ngx_cache_purge /usr/src/headers-more-nginx-module \
    && /sbin/apk del .build-deps \
    && /bin/rm -rf /var/cache/apk/*
#    
# END BUILD CUSTOM MODULES
#

# Error pages - https://github.com/alexphelps/server-error-pages
RUN set -x; \
    /sbin/apk add --no-cache --virtual .error-deps git; \
    \
    /usr/bin/git clone https://github.com/alexphelps/server-error-pages.git "$DEMYX_CONFIG"/error; \
    /bin/chown -R demyx:demyx "$DEMYX_CONFIG"/error; \
    \
    /sbin/apk del .error-deps; \
    /bin/rm -rf /var/cache/apk/*

# Packages
RUN set -ex; \
    /sbin/apk --update --no-cache add bash curl sudo

# Configure sudo
RUN set -ex; \
    \
    /bin/echo "demyx ALL=(ALL) NOPASSWD:SETENV: /usr/local/bin/demyx-entrypoint, /usr/local/bin/demyx-reload" > /etc/sudoers.d/demyx; \
    \
    /bin/touch /etc/nginx/stdout; \
    \
    /bin/chown demyx:demyx /etc/nginx/stdout

# Imports
COPY --chown=demyx:demyx src "$DEMYX_CONFIG"

# Finalize
RUN set -ex; \
    # demyx-default
    /bin/cp "$DEMYX_CONFIG"/default.sh /usr/local/bin/demyx-default; \
    /bin/chmod +x /usr/local/bin/demyx-default; \
    \
    # demyx-reload
    /bin/cp "$DEMYX_CONFIG"/reload.sh /usr/local/bin/demyx-reload; \
    /bin/chmod +x /usr/local/bin/demyx-reload; \
    \
    # demyx-wp
    /bin/cp "$DEMYX_CONFIG"/wp.sh /usr/local/bin/demyx-wp; \
    /bin/chmod +x /usr/local/bin/demyx-wp; \
    \
    # demyx-entrypoint
    /bin/cp "$DEMYX_CONFIG"/entrypoint.sh /usr/local/bin/demyx-entrypoint; \
    /bin/chmod +x /usr/local/bin/demyx-entrypoint; \
    \
    # Create copy of /etc/demyx in an archive
    /bin/tar -czf /etc/demyx.tgz -C "$DEMYX_CONFIG" .; \
    \
    # Reset permissions
    /bin/chown -R root:root /usr/local/bin

EXPOSE 80

WORKDIR "$DEMYX"

USER demyx

ENTRYPOINT ["/usr/bin/sudo", "-E", "/usr/local/bin/demyx-entrypoint"]
