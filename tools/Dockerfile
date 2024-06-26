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
    yq \
    coreutils \
    openldap-clients \
    openssh-client \
    httpie \
    apache2-utils \
    gettext \
    nginx \
    iperf3 \
    tzdata \
    mailx \
    mysql-client \
    mariadb-connector-c-dev \
    postgresql13-client \
    # allow unpriviledged access
    && mkdir -p /.httpie \
    && chgrp -R 0 /.httpie \
    && chmod -R g=u /.httpie \
    # allow unpriviledged access to update conf files
    && mkdir -p /var/lib/nginx/logs \
    && touch /var/lib/nginx/logs/error.log \
    && chgrp -R 0 /etc/nginx/ /var/log/ /var/lib/nginx /var/tmp/ /etc/passwd \
    && chmod -R g=u /etc/nginx/ /var/log/ /var/lib/nginx /var/tmp/ /etc/passwd \
    # Setup permissions to ssh configuration directory
    && mkdir -p /.ssh \
    && chmod -R 777 /.ssh \
    # ssh keys (testing only)
    && ssh-keygen -t ed25519 -a 100 -C "tools-insecure-ed25519 SSH key" -f  /root/.ssh/tools-insecure-ed25519 -P "" \
    && printf "Host *\n  IdentityFile /root/.ssh/tools-insecure-ed25519\n" >> /etc/ssh/ssh_config \
    # cleanup cache
    && rm -rf /var/cache /root/.cache
ENV TZ America/New_York
ENV LISTEN_PORT 8000
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
