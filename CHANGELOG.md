# CHANGELOG

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
