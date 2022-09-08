FROM alpine:latest
COPY ./bin/ /usr/local/bin/
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./nginx-conf-templates/ /etc/nginx/conf.d/templates
RUN set -x \
    && apk update \
    && apk add --no-cache --update \
    bash \
    ca-certificates \
    openssl \
    curl \
    bind-tools \
    netcat-openbsd \
    nmap \
    jq \
    coreutils \
    openldap-clients \
    openssh-client \
    httpie \
    apache2-utils \
    py-pip \
    gettext \
    nginx \
    iperf3 \
    tzdata \
    mysql-client \
    postgresql13-client \
    # pip packages
    && pip install yq \
    # allow unpriviledged access
    && mkdir -p /.httpie \
    && chgrp -R 0 /.httpie \
    && chmod -R g=u /.httpie \
    # allow unpriviledged access to update conf files
    && mkdir -p /var/lib/nginx/logs \
    && touch /var/lib/nginx/logs/error.log \
    && chgrp -R 0 /etc/nginx/ /var/log/ /var/lib/nginx /var/tmp/ \
    && chmod -R g=u /etc/nginx/ /var/log/ /var/lib/nginx /var/tmp/ \
    # ssh keys (testing only)
    && ssh-keygen -t ed25519 -a 100 -C "tools-insecure-ed25519 SSH key" -f  /root/.ssh/tools-insecure-ed25519 -P "" \
    && printf "Host *\n  IdentityFile /root/.ssh/tools-insecure-ed25519\n" >> /etc/ssh/ssh_config \
    # cleanup cache
    && find / | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf \
    && rm -rf /var/cache /root/.cache
ENV TZ America/New_York
ENV LISTEN_PORT 8000
