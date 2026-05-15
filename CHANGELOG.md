# Changelog

## 2026-05-09
### Added
- None.
### Changed
- Updated Nginx base image tag to `mainline-alpine3.22`.
- Scheduled build run.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2026-05-08
### Added
- None.
### Changed
- Updated Alpine base image to 3.21.
- Updated PHP to 8.3.
- Improved security configuration.
### Fixed
- Removed cache purge test and checked for FastCGI cache header instead.
### Removed
- None.
### Security
- None.

## 2025-07-28
### Added
- Added logrotate and apache2-utils to default packages.
- Added missing environment variables.
### Changed
- Complete rework of Nginx config template with new config files/modules and Nginx as PID 1.
- Updated environment variables.
- Added new sudo file.
- Made entrypoint executable for config regeneration.
- Updated GitHub Actions commit message format to include run ID.
- Updated project/support messaging.
### Fixed
- Added subshell error checks.
### Removed
- Removed old variables.
- Removed/renamed obsolete items.
### Security
- Compiled Brotli module.

## 2024-11-06
### Added
- Added missing variables.
### Changed
- None.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2024-11-05
### Added
- None.
### Changed
- Hard coded WordPress port.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2024-10-31
### Added
- Installed cache directory and symlinked Nginx core files.
- Added new sudo file.
- Added logrotate and apache2-utils default packages.
### Changed
- Reworked Nginx config template and related modules.
- Updated ENV variables.
- Updated entrypoint regeneration behavior.
- Updated project messaging links.
- Updated ownership for `/etc/demyx`.
### Fixed
- Added subshell error checking.
### Removed
- Removed old variables.
- Removed/renamed obsolete paths/items.
### Security
- Compiled Brotli module.

## 2024-05-07
### Added
- None.
### Changed
- Put current Demyx version into header.
- Updated header check logic.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2024-04-24
### Added
- Added `DEMYX_CACHE_INACTIVE` environment variable for cache expiration interval.
### Changed
- Updated `fastcgi_cache_path` values.
### Fixed
- Corrected unsupported `1g` value usage.
### Removed
- None.
### Security
- None.

## 2024-04-03
### Added
- None.
### Changed
- None.
### Fixed
- Fixed xmlrpc.php deny rule.
### Removed
- None.
### Security
- None.

## 2024-02-07
### Added
- Added support for WP Rocket via `rocket-nginx`.
- Added new environment variable support.
### Changed
- Updated description/support links.
- Moved `RUN` commands earlier in Dockerfile flow.
- Switched to `more_set_headers`.
### Fixed
- Doubled upload limit.
- Fixed base image to Alpine 3.18.
### Removed
- None.
### Security
- None.

## 2023-11-13
### Added
- None.
### Changed
- Completely restructured directories and files.
- Updated include rules and path logic.
- Updated override conditionals.
- Updated envsubst parsing behavior.
### Fixed
- Combined duplicate rules.
- Added file-existence checks.
- Removed duplicate entries.
### Removed
- None.
### Security
- None.

## 2023-09-19
### Added
- Added tests for headers and cache.
### Changed
- Misc updates.
### Fixed
- Fixed cache purging issue.
### Removed
- None.
### Security
- None.

## 2023-08-17
### Added
- None.
### Changed
- None.
### Fixed
- Fixed multiple IP bug.
### Removed
- None.
### Security
- None.

## 2023-08-10
### Added
- Added missing variables.
### Changed
- Included format and usage tip.
### Fixed
- Fixed basic auth `if` statement with missing variable.
### Removed
- None.
### Security
- None.

## 2023-07-16
### Added
- None.
### Changed
- Updated WooCommerce directives.
- Switched to bash replace function.
- Misc updates.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2023-07-06
### Added
- None.
### Changed
- None.
### Fixed
- Fixed error log local time handling.
### Removed
- None.
### Security
- None.

## 2023-07-05
### Added
- None.
### Changed
- Misc update.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2022-06-24
### Added
- None.
### Changed
- Corrected package name.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2022-05-19
### Added
- Added missing `fastcgi_param` for `wp-cron.php`.
### Changed
- None.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2021-07-14
### Added
- None.
### Changed
- Used `nginx -v` for version extraction.
- Switched `FROM` image to `nginx:mainline-alpine`.
- Updated distro base.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2021-06-16
### Added
- Added missing environment variables.
### Changed
- Updated `ngx_cache_purge` repository.
### Fixed
- None.
### Removed
- Removed unused environment variables.
### Security
- None.

## 2021-02-25
### Added
- Added `bin/demyx-default`, `bin/demyx-entrypoint`, `bin/demyx-reload`, and `bin/demyx-wp`.
- Added `config/cache/http.conf`, `config/cache/location.conf`, and `config/cache/server.conf`.
- Added common and nginx config files for auth, bedrock, mime types, WordPress, and xmlrpc handling.
### Changed
- Renamed `src` to `bin` and renamed script files to `demyx-*` variants.
- Moved `src/cache`, `src/common`, and `src/nginx` into `config` paths.
- Removed full binary paths across shell scripts.
- Updated Dockerfile `RUN` flow, bash `PS1`, and `COPY` directory.
- Removed duplicate access/error log rules and `fastcgi_intercept_errors` in `demyx-wp`.
### Fixed
- None.
### Removed
- Removed `common/error.conf`.
### Security
- None.

## 2020-12-21
### Added
- None.
### Changed
- Disabled custom 500 error page.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2020-12-05
### Added
- None.
### Changed
- Updated path to `tar`.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2020-12-04
### Added
- Added `fastcgi_intercept_errors` rule.
### Changed
- Updated `RUN` commands for Demyx configuration.
- Used WordPress 404 page instead of Nginx default.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2020-11-23
### Added
- None.
### Changed
- Alphabetized configuration/variables.
- Misc updates.
- Renamed variables and supported old names.
- Updated Dockerfile `RUN` commands.
- Used `sudo -E` for environment variable preservation.
- Used full paths to binaries/scripts.
### Fixed
- ShellCheck compliance improvements.
### Removed
- None.
### Security
- None.

## 2020-06-23
### Added
- None.
### Changed
- Updated author ID enumeration security rule to allow XML exports.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2020-06-21
### Added
- None.
### Changed
- Updated IP whitelist variables.
- Enabled gzip for `wp-content` assets.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2020-06-13
### Added
- Added `NGINX_WHITELIST`, `NGINX_WHITELIST_IP`, and `NGINX_WHITELIST_TYPE` environment variables.
### Changed
- Moved `auth_basic` to its own file.
### Fixed
- Fixed `wp-config.php` deny behavior.
### Removed
- None.
### Security
- None.

## 2020-06-07
### Added
- None.
### Changed
- Moved `nginx.pid` to `/tmp`.
- Generated Demyx config when missing.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2020-05-31
### Added
- None.
### Changed
- Switched shell script shebangs to bash.
- Derived Alpine version from `FROM` image.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2020-05-08
### Added
- None.
### Changed
- Moved default `WORDPRESS` environment variable to Dockerfile.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2020-04-17
### Added
- Added `reload.sh` to sudoers.
### Changed
- Updated ownership for Demyx directories.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2020-04-15
### Added
- None.
### Changed
- Used `demyx-entrypoint` in sudoers.
- Set log ownership to Demyx user.
### Fixed
- None.
### Removed
- None.
### Security
- None.

## 2020-04-14
### Added
- Created source directory structure for main and nginx files.
- Added additional FastCGI rules.
- Added `.webp` support.
- Added custom `mime.types`.
### Changed
- Modified `fastcgi_cache_path` parameters.
- Moved cache status to main `nginx.conf`.
- Moved `bedrock.conf` path.
- Updated log format.
- Included homepage URL in `X-Powered-By`.
- Set `dumb-init` as entrypoint shebang.
- Formatted `LABEL` and `ENV` entries.
- Updated final `RUN` commands.
- Updated `ENTRYPOINT`.
- Updated sudo environment handling.
### Fixed
- None.
### Removed
- Removed headers.
### Security
- None.
