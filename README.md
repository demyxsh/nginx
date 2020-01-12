# nginx
[![Build Status](https://img.shields.io/travis/demyxco/nginx?style=flat)](https://travis-ci.org/demyxco/nginx)
[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/nginx?style=flat&color=blue)](https://hub.docker.com/r/demyx/nginx)
[![Architecture](https://img.shields.io/badge/linux-amd64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/nginx)
[![Alpine](https://img.shields.io/badge/alpine-3.10.3-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/nginx)
[![NGINX](https://img.shields.io/badge/nginx-1.17.7-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/nginx)
[![Buy Me A Coffee](https://img.shields.io/badge/buy_me_coffee-$5-informational?style=flat&color=blue)](https://www.buymeacoffee.com/VXqkQK5tb)
[![Become a Patron!](https://img.shields.io/badge/become%20a%20patron-$5-informational?style=flat&color=blue)](https://www.patreon.com/bePatron?u=23406156)

Non-root Docker image running Alpine Linux and NGINX.

DEMYX | NGINX
--- | ---
TAGS | latest
PORT | 80
USER | demyx
WORKDIR | /demyx
CONFIG | /etc/demyx
ENTRYPOINT | ["dumb-init", "demyx"]
TIMEZONE | America/Los_Angeles

## Usage
* To generate htpasswd: `docker run -it --rm demyx/utilities "htpasswd -nb demyx demyx"`
* NGINX_BASIC_AUTH must have double dollar signs ($$)

```
docker run -dit --rm \
--name nginx \
-e NGINX_ROOT=/demyx \
-e NGINX_CONFIG=/etc/demyx \
-e NGINX_LOG=/var/log/demyx \
-e WORDPRESS="true" \               # Only set to true if using for WordPress
-e WORDPRESS_CONTAINER=wp \         # PHP/WordPress container name
-e WORDPRESS_CONTAINER_PORT=9000 \  # PHP/WordPress container port
-e NGINX_DOMAIN=domain.tld \        # WordPress only setting
-e NGINX_UPLOAD_LIMIT=128M \        # WordPress only setting
-e NGINX_CACHE=false \              # WordPress only setting
-e NGINX_RATE_LIMIT=false \         # WordPress only setting
-e NGINX_XMLRPC=false \             # WordPress only setting
-e NGINX_BASIC_AUTH=false \         # WordPress only setting
-e NGINX_BASIC_AUTH_HTPASSWD= \     # WordPress only setting
-e TZ=America/Los_Angeles \
demyx/nginx
```

## Updates & Support
[![Code Size](https://img.shields.io/github/languages/code-size/demyxco/nginx?style=flat&color=blue)](https://github.com/demyxco/nginx)
[![Repository Size](https://img.shields.io/github/repo-size/demyxco/nginx?style=flat&color=blue)](https://github.com/demyxco/nginx)
[![Watches](https://img.shields.io/github/watchers/demyxco/nginx?style=flat&color=blue)](https://github.com/demyxco/nginx)
[![Stars](https://img.shields.io/github/stars/demyxco/nginx?style=flat&color=blue)](https://github.com/demyxco/nginx)
[![Forks](https://img.shields.io/github/forks/demyxco/nginx?style=flat&color=blue)](https://github.com/demyxco/nginx)

* Auto built weekly on Sundays (America/Los_Angeles)
* Rolling release updates
* For support: [#demyx](https://webchat.freenode.net/?channel=#demyx)
