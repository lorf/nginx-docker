# This docker file installs nginx build deps and unpacks nginx source
# For use as a build image for building other nginx modules

FROM nginxinc/nginx-unprivileged:stable

USER root

RUN set -x && \
    NGINX_VERSION=$(nginx -v 2>&1 | cut -f2 -d/) && \
    echo $NGINX_VERSION >/usr/src/nginx-version && \
    PACKAGES="nginx=$NGINX_VERSION" && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y gnupg1 apt-transport-https ca-certificates git && \
    echo "deb-src https://nginx.org/packages/debian/ stretch nginx" >> /etc/apt/sources.list.d/nginx.list && \
    apt-get update && \
    apt-get build-dep -y nginx=$NGINX_VERSION && \
    cd /usr/src && \
    apt-get source nginx=$NGINX_VERSION && \
    echo "You may safely ignore \"Permission denied\" warning above" >&2 && \
    ln -sf /usr/src/nginx-$NGINX_VERSION /usr/src/nginx && \
    rm -rf /var/lib/apt/lists/*
