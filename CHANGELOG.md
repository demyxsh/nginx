# CHANGELOG

## 2023-09-19
- Fix cache purging issue [49ed4bf](https://github.com/demyxsh/nginx/commit/49ed4bff8aa33424e7539b15e6ae906fd919c535)

## 2023-08-17
- Fix multiple IP bug [9743a9b](https://github.com/demyxsh/nginx/commit/9743a9b863eb4d235945af2566dde06810fa888e)

## 2023-08-10
- Include format and tip [6f0c133](https://github.com/demyxsh/nginx/commit/6f0c1333aea0d91615fddc09573cf9e6ec246706)
- Update basic auth if statement with missing variable [cb27cc6](https://github.com/demyxsh/nginx/commit/cb27cc63c2b8e682e6ec6f8414cdefe61270a8c7)
- Adding missing variable [3ee857e](https://github.com/demyxsh/nginx/commit/3ee857ef2ba47ce22fdc6285798ef579712599b8)

## 2023-07-16
- Misc updates [bffd8dd](https://github.com/demyxsh/nginx/commit/bffd8dd2f5c256e853150b7e3f35a0799e95040d)
- Update directives for WooCommerce [7408f0e](https://github.com/demyxsh/nginx/commit/7408f0ec07d8bbf83de2cc5599983e5b22c84c18)
- Use bash replace function [bcee331](https://github.com/demyxsh/nginx/commit/bcee33183852285e7f6c1deb199c4fdccd8c1c57)

## 2023-07-06
- Error log wasn't showing local time [a433294](https://github.com/demyxsh/nginx/commit/a433294dac86d824f5047e1a2f3233ef73b6464b)

## 2023-07-05
- Misc update [97724b4](https://github.com/demyxsh/nginx/commit/97724b43a6e2568b55e96282e52c57c20e99366b)

## 2022-06-24
- Correct package name [a36adca](https://github.com/demyxsh/nginx/commit/a36adca1fa9f69a6ea9ab28ba592f582f8562dc5)

## 2022-05-19
- Add missing fastcgi_param for wp-cron.php [3097f64](https://github.com/demyxsh/nginx/commit/3097f642e4060c32489ac7181cd784a1e57dc3c5)

## 2021-07-14
- Use nginx -v instead to get version [c9a5a8f](https://github.com/demyxsh/nginx/commit/c9a5a8f12fe1f43390753039569d042087299ac4)
- Use nginx:mainline-alpine as the FROM image [f07028f](https://github.com/demyxsh/nginx/commit/f07028fc87a78f29859f79e9410d9e78e3e66941)
- Use latest distro [218ffc4](https://github.com/demyxsh/nginx/commit/218ffc4f0e353972dba9be2fb4e24dfed5e715e2)

## 2021-06-16
- Add missing environment variables [f0798bf](https://github.com/demyxsh/nginx/commit/f0798bf02b9d3c8d83cb01d6ecc326f244c4e395)
- Update ngx_cache_purge repo [8da2097](https://github.com/demyxsh/nginx/commit/8da209764dd8fbb7f72393e8fe52bbf2b8ab8e06)
- Remove unused ENV [e10a886](https://github.com/demyxsh/nginx/commit/e10a88645d31bf35ea887297aa184e2c9bbdda75)

## 2021-02-25
- Added
    - `bin/demyx-default`
    - `bin/demyx-entrypoint`
    - `bin/demyx-reload`
    - `bin/demyx-wp`
    - `config/cache/http.conf`
    - `config/cache/location.conf`
    - `config/cache/server.conf`
    - `common/locations.conf`
    - `common/wpcommon.conf`
    - `common/xmlrpc.conf`
    - `nginx/auth.conf`
    - `nginx/bedrock.conf`
    - `nginx/mime.types`
- Changed
    - Renamed src to bin.
    - Renamed default.sh to demyx-default.
    - Renamed entrypoint.sh to demyx-entrypoint.
    - Renamed reload.sh to demyx-reload.
    - Renamed wp.sh to demyx-wp.
    - Move src/cache to config.
    - Move src/common to config.
    - Move src/nginx to config.
    - `bin/demyx-default`
        - Remove full paths to binaries.
    - `bin/demyx-entrypoint`
        - Remove full paths to binaries.
    - `bin/demyx-reload`
        - Remove full paths to binaries.
    - `bin/demyx-wp`
        - Remove full paths to binaries.
        - Remove duplicate access/error log rules.
        - Remove fastcgi_intercept_errors.
    - `Dockerfile`
        - Remove full paths to binaries.
        - Rearrange RUN commands.
        - Update bash PS1.
        - Update COPY directory.
        - Remove custom error pages.
- Removed
    - `common/error.conf`

## 2020-12-21
### Changed
- Disable custom 500 error page

## 2020-12-05
### Changed
- Update path to tar

## 2020-12-04
### Added
- fastcgi_intercept_errors rule
### Changed
- Update RUN commands for configuring demyx
- Use WordPress' 404 page instead of nginx

## 2020-11-23
### Changed
- Alphabetized
- Misc updates
- Rename variables and support old ones
- ShellCheck approved
- Update Dockerfile RUN commands
- Use -E flag for sudo to keep environment variables
- Use full paths to binaries/scripts

## 2020-06-23
### Changed
- Update author ID enumeration security rule which was preventing XML exports

## 2020-06-21
### Changed
- Update variables for IP whitelisting
- Enable gzip for wp-content assets

## 2020-06-13
### Added
- New environment variables NGINX_WHITELIST, NGINX_WHITELIST_IP, and NGINX_WHITELIST_TYPE
### Changed
- wp-config.php wasn't properly being denied
- Moved auth_basic to its own file

## 2020-06-07
### Changed
- Move nginx.pid to /tmp
- Generate demyx config if it doesn't exist

## 2020-05-31
### Changed
- Shell scripts now uses bash in the shebang
- Get and use alpine version from FROM

## 2020-05-08
### Changed
- Move default WORDPRESS environment variable to Dockerfile

## 2020-04-17
### Added
- Allow reload.sh to sudoers
### Changed
- chown demyx directories

## 2020-04-15
### Changed
- Use demyx-entrypoint in sudoers
- Set log ownership to demyx user

## 2020-04-14
### Added
- Created src for main files
- Created src/nginx for misc files
- Added more fastcgi rules
- .webp support
- src/nginx directory for misc files
- Custom mime.types
### Changed
- Modified fastcgi_cache_path params
- Cache status has been moved to main nginx.conf
- move bedrock.conf to src/nginx
- Log format
- Include homepage url to X-Powered-By
- Set dumb-init as the shebang in the entrypoint
- Format LABEL and ENV entries
- Update finalize RUN commands
- Update ENTRYPOINT
- Update sudo environment
### Removed
- Headers
