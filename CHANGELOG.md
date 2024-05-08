# CHANGELOG

## 2024-05-07
- Put current version of Demyx into the header [8712158](https://github.com/demyxsh/nginx/commit/871215837728e32d344ceb33af21f3f3d1b5d0ae)

## 2024-04-24
- Add new environment variable to control cache expiration interval `DEMYX_CACHE_INACTIVE` [a92c41e](https://github.com/demyxsh/nginx/commit/a92c41ec1dcc1de9f603426c0c99f57ae1c86382)
- Apparently 1g isn't accepted [a86f101](https://github.com/demyxsh/nginx/commit/a86f101148bbf2ae7c5953ab35914fecebb657bd)
- Update fastcgi_cache_path values [cc72e38](https://github.com/demyxsh/nginx/commit/cc72e388201b4faa6d95474365078fc6e192427d)

## 2024-04-03
- xmlrpc.php wasn't being denied properly [8e41ea4](https://github.com/demyxsh/nginx/commit/8e41ea4702fde761c8ccd126080d9e96ea2015eb)

## 2024-02-07
- Update shamless plug [44d302f](https://github.com/demyxsh/nginx/commit/44d302f324f2e8eddf3bada5315c391e78da8cdb)
- Double upload limit [d11a61e](https://github.com/demyxsh/nginx/commit/d11a61e385603d6dc70573338d71bfb2202bcf31)
- 2024-02-07 [2d5c8f6](https://github.com/demyxsh/nginx/commit/2d5c8f6adb3d63376afc7ec35d0b352c5a259425)
- Merge branch 'master' of github.com:demyxsh/nginx [041d1e2](https://github.com/demyxsh/nginx/commit/041d1e27f67a2616667b0426f92e2d2ceb41decb)
- Update description with shameless plug and support link [b32c678](https://github.com/demyxsh/nginx/commit/b32c678347a280f1d86f8656d925ebaffe4955a6)
- Support for WP Rocket with [rocket-nginx](https://github.com/SatelliteWP/rocket-nginx) [77b86de](https://github.com/demyxsh/nginx/commit/77b86dea6f3a27bd52c3ed0f722a2a18decfe0fd)
- Move RUN commands up [e98768a](https://github.com/demyxsh/nginx/commit/e98768a1e3b40534f9bb0c7f044e3dacb93ff860)
- Add new environment variable [5be7fa7](https://github.com/demyxsh/nginx/commit/5be7fa72345d03f498c404b7d2523932074801c5)
- Fix base image to Alpine 3.18 [754af4a](https://github.com/demyxsh/nginx/commit/754af4a4ea2c32cb1b8d5ad84908cff3eaed92fe)
- Switch to more_set_headers [02eb584](https://github.com/demyxsh/nginx/commit/02eb584a565d156638ca3eedfbae665590f52d10)

## 2023-11-13
- Combine duplicate rules [40c75ca](https://github.com/demyxsh/nginx/commit/40c75cae5241a3eea34293c19fb981a90784d0e4)
- Check if file exists [a92dd21](https://github.com/demyxsh/nginx/commit/a92dd214ccedde22f83f266571de90e714670605)
- Remove duplicates [d95a4ff](https://github.com/demyxsh/nginx/commit/d95a4ff4b90ca9ad6fd5e2a1ffa06dd741368d67)
- Completely restructure directories and files [b60e961](https://github.com/demyxsh/nginx/commit/b60e961cdd42bbdc2c5f1d3a32961687031f9cc1)
- envsubst so variables are parsed [5dbd163](https://github.com/demyxsh/nginx/commit/5dbd1634a072185305323c2af3d59779ca901aad)
- Use new include rule [1745b08](https://github.com/demyxsh/nginx/commit/1745b088a6791cafe0f8b0c394fb027afd6cb0d4)
- User override conditionals [85efc1d](https://github.com/demyxsh/nginx/commit/85efc1dc4dbe7faa5e66092ac87c620ff1e46753)
- Use new paths and update logic [0466bef](https://github.com/demyxsh/nginx/commit/0466befa118d21ff1d5bddb1e1483403a3444990)
- Update logic [308ca89](https://github.com/demyxsh/nginx/commit/308ca89e17988642064aac6b97f85a905f994b16)

## 2023-09-19
- Fix cache purging issue [49ed4bf](https://github.com/demyxsh/nginx/commit/49ed4bff8aa33424e7539b15e6ae906fd919c535)
- Misc updates [6367d4f](https://github.com/demyxsh/nginx/commit/6367d4f2c8dbfc472bd2a5d45a41882111ce549c)
- Add tests for headers and cache [2855fcb](https://github.com/demyxsh/nginx/commit/2855fcbe17d731740d7dcf1d64b1a7c9b6c40056)

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
