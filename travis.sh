#!/bin/bash
# Demyx
# https://demyx.sh

# Get versions
DEMYX_NGINX_ALPINE_VERSION="$(/usr/bin/docker exec "$DEMYX_REPOSITORY" /bin/cat /etc/os-release | /bin/grep VERSION_ID | /usr/bin/cut -c 12- | /bin/sed 's/\r//g')"
DEMYX_NGINX_VERSION="$(/usr/bin/docker exec "$DEMYX_REPOSITORY" /usr/sbin/"$DEMYX_REPOSITORY" -V 2>&1 | /usr/bin/head -n 1 | /usr/bin/cut -c 22- | /bin/sed 's/\r//g')"

# Replace versions
/bin/sed -i "s|alpine-.*.-informational|alpine-${DEMYX_NGINX_ALPINE_VERSION}-informational|g" README.md
/bin/sed -i "s|$DEMYX_REPOSITORY-.*.-informational|$DEMYX_REPOSITORY-${DEMYX_NGINX_VERSION}-informational|g" README.md

# Echo versions to file
/bin/echo "DEMYX_NGINX_ALPINE_VERSION=$DEMYX_NGINX_ALPINE_VERSION
DEMYX_NGINX_VERSION=$DEMYX_NGINX_VERSION" > VERSION

# Push back to GitHub
/usr/bin/git config --global user.email "travis@travis-ci.com"
/usr/bin/git config --global user.name "Travis CI"
/usr/bin/git remote set-url origin https://"$DEMYX_GITHUB_TOKEN"@github.com/demyxco/"$DEMYX_REPOSITORY".git
# Push VERSION file first
/usr/bin/git add VERSION
/usr/bin/git commit -m "ALPINE $DEMYX_NGINX_ALPINE_VERSION, NGINX $DEMYX_NGINX_VERSION"
/usr/bin/git push origin HEAD:master
# Add and commit the rest
/usr/bin/git add .
/usr/bin/git commit -m "Travis Build $TRAVIS_BUILD_NUMBER"
/usr/bin/git push origin HEAD:master

# Send a PATCH request to update the description of the repository
/bin/echo "Sending PATCH request"
DEMYX_DOCKER_TOKEN="$(/usr/bin/curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'"$DEMYX_USERNAME"'", "password": "'"$DEMYX_PASSWORD"'"}' "https://hub.docker.com/v2/users/login/" | /usr/local/bin/jq -r .token)"
DEMYX_RESPONSE_CODE="$(/usr/bin/curl -s --write-out "%{response_code}" --output /dev/null -H "Authorization: JWT ${DEMYX_DOCKER_TOKEN}" -X PATCH --data-urlencode full_description@"README.md" "https://hub.docker.com/v2/repositories/${DEMYX_USERNAME}/${DEMYX_REPOSITORY}/")"
/bin/echo "Received response code: $DEMYX_RESPONSE_CODE"

# Return an exit 1 code if response isn't 200
[[ "$DEMYX_RESPONSE_CODE" != 200 ]] && exit 1
