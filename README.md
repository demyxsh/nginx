# nginx
[![demyxsh/nginx](https://github.com/demyxsh/nginx/actions/workflows/main.yml/badge.svg)](https://github.com/demyxsh/nginx/actions/workflows/main.yml)
[![Code Size](https://img.shields.io/github/languages/code-size/demyxsh/nginx?style=flat&color=blue)](https://github.com/demyxsh/nginx)
[![Repository Size](https://img.shields.io/github/repo-size/demyxsh/nginx?style=flat&color=blue)](https://github.com/demyxsh/nginx)
[![Watches](https://img.shields.io/github/watchers/demyxsh/nginx?style=flat&color=blue)](https://github.com/demyxsh/nginx)
[![Stars](https://img.shields.io/github/stars/demyxsh/nginx?style=flat&color=blue)](https://github.com/demyxsh/nginx)
[![Forks](https://img.shields.io/github/forks/demyxsh/nginx?style=flat&color=blue)](https://github.com/demyxsh/nginx)
[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/nginx?style=flat&color=blue)](https://hub.docker.com/r/demyx/nginx)
[![Architecture](https://img.shields.io/badge/linux-amd64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/nginx)
[![Alpine](https://img.shields.io/badge/dynamic/json?url=https://github.com/demyxsh/nginx/raw/master/version.json&label=alpine&query=$.alpine&color=blue)](https://hub.docker.com/r/demyx/nginx)
[![NGINX](https://img.shields.io/badge/dynamic/json?url=https://github.com/demyxsh/nginx/raw/master/version.json&label=nginx&query=$.nginx&color=blue)](https://hub.docker.com/r/demyx/nginx)
[![Buy Me A Coffee](https://img.shields.io/badge/buy_me_coffee-$5-informational?style=flat&color=blue)](https://www.buymeacoffee.com/VXqkQK5tb)
[![Become a Patron!](https://img.shields.io/badge/become%20a%20patron-$5-informational?style=flat&color=blue)](https://www.patreon.com/bePatron?u=23406156)

Non-root Docker image running Alpine Linux and NGINX.

To properly utilize this image, please use [Demyx](https://demyx.sh/readme).
- Repository - [demyxsh/demyx](https://github.com/demyxsh/demyx)
- Homepage - [demyx.sh](https://demyx.sh)

[![Demyx Discord](https://discordapp.com/api/guilds/1152828583446859818/widget.png?style=banner2)](https://demyx.sh/discord)

Join us on Discord for latest news, faster support, or just chill.

<a href="https://demyx.sh/sponsor-buymeacoffee" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

Support this project by buying coffee (please).

DEMYX | NGINX
--- | ---
TAGS | latest
PORT | 80
USER | demyx
WORKDIR | /demyx
CONFIG | /etc/demyx
ENTRYPOINT | /usr/bin/sudo -E demyx-entrypoint
TIMEZONE | America/Los_Angeles

## NOTICE
This repository has been moved to the organization [demyxsh](https://github.com/demyxsh); please update the remote URL.
```
git remote set-url origin git@github.com:demyxsh/nginx.git
```

## Usage
* To generate htpasswd: `docker run -it --rm demyx/utilities "htpasswd -nb demyx demyx"`
* DEMYX_BASIC_AUTH_HTPASSWD must have double dollar signs ($$)
* DEMYX_WHITELIST accepted values: all, login
* DEMYX_WHITELIST_IP must have a valid IP address, multiple IPs in csv

```
docker run -dit --rm \
--name=nginx \
-e DEMYX_BASIC_AUTH=false \                 # WordPress only setting
-e DEMYX_BASIC_AUTH_HTPASSWD=false \        # WordPress only setting (format: username:password using apache2-utils or others)
-e DEMYX_BEDROCK=false \                    # Bedrock only setting
-e DEMYX_CACHE=false \                      # WordPress only setting
-e DEMYX_CACHE_TYPE=default \               # WordPress only setting
-e DEMYX_DOMAIN=localhost \                 # WordPress only setting
-e DEMYX_RATE_LIMIT=false \                 # WordPress only setting
-e DEMYX_UPLOAD_LIMIT=256M \                # WordPress only setting
-e DEMYX_WHITELIST=false \                  # WordPress only setting
-e DEMYX_WHITELIST_IP=false \               # WordPress only setting
-e DEMYX_WHITELIST_TYPE=false \             # WordPress only setting
-e DEMYX_WORDPRESS=false \                  # Only set to true if using for WordPress
-e DEMYX_WORDPRESS_CONTAINER=wp \           # PHP/WordPress container name
-e DEMYX_WORDPRESS_CONTAINER_PORT=9000 \    # PHP/WordPress container port
-e DEMYX_XMLRPC=false \
demyx/nginx
```

## Updates & Support
- Auto built weekly on Saturdays (America/Los_Angeles)
- Rolling release updates
- For support: [Discord](https://demyx.sh/discord)
