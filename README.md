# nginx
[![Build Status](https://img.shields.io/travis/demyxco/nginx?style=flat)](https://travis-ci.org/demyxco/nginx)
[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/nginx?style=flat&color=blue)](https://hub.docker.com/r/demyx/nginx)
[![Architecture](https://img.shields.io/badge/linux-amd64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/nginx)
[![Alpine](https://img.shields.io/badge/alpine-3.10.2-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/nginx)
[![NGINX](https://img.shields.io/badge/nginx-1.17.3-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/nginx)

nginx [engine x] is an HTTP and reverse proxy server, a mail proxy server, and a generic TCP/UDP proxy server, originally written by Igor Sysoev.

TITLE | DESCRIPTION
--- | ---
PORT | 80
TIMEZONE | America/Los_Angeles
NGINX | /etc/nginx/nginx.conf<br />/etc/nginx/cache<br />/etc/nginx/common<br />/etc/nginx/modules<br />

# Updates
[![Code Size](https://img.shields.io/github/languages/code-size/demyxco/nginx?style=flat&color=blue)](https://github.com/demyxco/nginx)
[![Repository Size](https://img.shields.io/github/repo-size/demyxco/nginx?style=flat&color=blue)](https://github.com/demyxco/nginx)
[![Watches](https://img.shields.io/github/watchers/demyxco/nginx?style=flat&color=blue)](https://github.com/demyxco/nginx)
[![Stars](https://img.shields.io/github/stars/demyxco/nginx?style=flat&color=blue)](https://github.com/demyxco/nginx)
[![Forks](https://img.shields.io/github/forks/demyxco/nginx?style=flat&color=blue)](https://github.com/demyxco/nginx)

* Auto built weekly on Sundays (America/Los_Angeles)
* Rolling release updates

# Usage
```
nginx:
    container_name: nginx
    image: demyx/nginx
    restart: unless-stopped
    environment:
      nginx_DATABASE: demyx_db
      nginx_USERNAME: demyx_user
      nginx_PASSWORD: demyx_password
      nginx_ROOT_PASSWORD: demyx_root_password # mandatory
      nginx_DEFAULT_CHARACTER_SET: utf8
      nginx_CHARACTER_SET_SERVER: utf8
      nginx_COLLATION_SERVER: utf8_general_ci
      nginx_KEY_BUFFER_SIZE: 32M
      nginx_MAX_ALLOWED_PACKET: 16M
      nginx_TABLE_OPEN_CACHE: 2000
      nginx_SORT_BUFFER_SIZE: 4M
      nginx_NET_BUFFER_SIZE: 4M
      nginx_READ_BUFFER_SIZE: 2M
      nginx_READ_RND_BUFFER_SIZE: 1M
      nginx_MYISAM_SORT_BUFFER_SIZE: 32M
      nginx_LOG_BIN: mysql-bin
      nginx_BINLOG_FORMAT: mixed
      nginx_SERVER_ID: 1
      nginx_INNODB_DATA_FILE_PATH: ibdata1:10M:autoextend
      nginx_INNODB_BUFFER_POOL_SIZE: 32M
      nginx_INNODB_LOG_FILE_SIZE: 5M
      nginx_INNODB_LOG_BUFFER_SIZE: 8M
      nginx_INNODB_FLUSH_LOG_AT_TRX_COMMIT: 1
      nginx_INNODB_LOCK_WAIT_TIMEOUT: 50
      nginx_INNODB_USE_NATIVE_AIO: 1
      nginx_READ_BUFFER: 2M
      nginx_WRITE_BUFFER: 2M
      nginx_MAX_CONNECTIONS: 100
      TZ: America/Los_Angeles
    volumes:
      - ./db:/var/lib/mysql
```
