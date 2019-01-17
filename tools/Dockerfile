FROM alpine:latest
RUN set -x; \
    apk update && \
    # system packages
    apk add --no-cache --update \
    bash \
    ca-certificates \
    openssl \
    curl \
    bind-tools \
    netcat-openbsd \
    jq \
    coreutils \
    openldap-clients \
    httpie \
    apache2-utils \
    py-pip \
    gettext \
    nginx \
    && \
    # pip packages
    pip install yq \
    && \
    # allow unpriviledged access
    mkdir -p /.httpie && \
    chgrp -R 0 /.httpie && \
    chmod -R g=u /.httpie \
    && \
    # allow unpriviledged access to update conf files
    chgrp -R 0 /etc/nginx/nginx.conf \
    && chmod -R g=u /etc/nginx/nginx.conf \
    && chgrp -R 0 /etc/nginx/conf.d/ \
    && chmod -R g=u /etc/nginx/conf.d/ \
    && \
    # cleanup cache
    find / | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf && \
    rm -rf /var/cache/* /root/.cache/*
COPY ./bin/ /usr/local/bin/
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./nginx-conf-templates/ /etc/nginx/conf.d/templates
ENV LISTEN_PORT 8000
