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

# Install NGINX
RUN set -x \
# create nginx user/group first, to be consistent throughout docker variants
    && export NGINX_MAINLINE_DOCKERFILE="$(wget -qO- https://raw.githubusercontent.com/nginxinc/docker-nginx/master/mainline/alpine/Dockerfile)" \
    && export NGINX_VERSION="$(echo "$NGINX_MAINLINE_DOCKERFILE" | grep 'ENV NGINX_VERSION' | cut -c 19-)" \
    && export NJS_VERSION="$(echo "$NGINX_MAINLINE_DOCKERFILE" | grep 'ENV NJS_VERSION' | cut -c 19-)" \
    && export PKG_RELEASE="$(echo "$NGINX_MAINLINE_DOCKERFILE" | grep 'ENV PKG_RELEASE' | cut -c 19-)" \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apkArch="$(cat /etc/apk/arch)" \
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
            && KEY_SHA512="e7fa8303923d9b95db37a77ad46c68fd4755ff935d0a534d26eba83de193c76166c68bfe7f65471bf8881004ef4aa6df3e34689c305662750c0172fca5d8552a *stdin" \
            && apk add --no-cache --virtual .cert-deps \
                openssl \
            && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
            && if [ "$(openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout | openssl sha512 -r)" = "$KEY_SHA512" ]; then \
                echo "key verification succeeded!"; \
                mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
            else \
                echo "key verification failed!"; \
                exit 1; \
            fi \
            && apk del .cert-deps \
            && apk add -X "https://nginx.org/packages/mainline/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache $nginxPackages \
            ;; \
        *) \
# we're on an architecture upstream doesn't officially build for
# let's build binaries from the published packaging sources
            set -x \
            && tempDir="$(mktemp -d)" \
            && chown nobody:nobody $tempDir \
            && apk add --no-cache --virtual .build-deps \
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
            && su nobody -s /bin/sh -c " \
                export HOME=${tempDir} \
                && cd ${tempDir} \
                && hg clone https://hg.nginx.org/pkg-oss \
                && cd pkg-oss \
                && hg up ${NGINX_VERSION}-${PKG_RELEASE} \
                && cd alpine \
                && make all \
                && apk index -o ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz ${tempDir}/packages/alpine/${apkArch}/*.apk \
                && abuild-sign -k ${tempDir}/.abuild/abuild-key.rsa ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz \
                " \
            && cp ${tempDir}/.abuild/abuild-key.rsa.pub /etc/apk/keys/ \
            && apk del .build-deps \
            && apk add -X ${tempDir}/packages/alpine/ --no-cache $nginxPackages \
            ;; \
    esac \
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then rm -rf "$tempDir"; fi \
    && if [ -n "/etc/apk/keys/abuild-key.rsa.pub" ]; then rm -f /etc/apk/keys/abuild-key.rsa.pub; fi \
    && if [ -n "/etc/apk/keys/nginx_signing.rsa.pub" ]; then rm -f /etc/apk/keys/nginx_signing.rsa.pub; fi \
# Bring in gettext so we can get `envsubst`, then throw
# the rest away. To do this, we need to install `gettext`
# then move `envsubst` out of the way so `gettext` can
# be deleted completely, then move `envsubst` back.
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache $runDeps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
# Bring in tzdata so users could set the timezones through the environment
# variables
    && apk add --no-cache tzdata \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

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
    echo 'Defaults env_keep +="NGINX_CACHE"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="NGINX_RATE_LIMIT"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="NGINX_XMLRPC"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="WORDPRESS_NGINX_BASIC_AUTH"' >> /etc/sudoers.d/demyx; \
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
