FROM frolvlad/alpine-glibc:latest
RUN set -x; \
    apk update && \
    apk add --no-cache --update \
    tar \
    gzip \
    bash \
    ca-certificates \
    gettext \
    curl \
    jq \
    && \
    OC_VERSION=v3.11.0 && \
    OC_TAG_SHA=0cbc58b && \
    curl -sLo /tmp/oc.tar.gz "https://github.com/openshift/origin/releases/download/$OC_VERSION/openshift-origin-client-tools-$OC_VERSION-$OC_TAG_SHA-linux-64bit.tar.gz" && \
    tar xzvf /tmp/oc.tar.gz -C /tmp/ && \
    mv /tmp/openshift-origin-client-tools-${OC_VERSION}-${OC_TAG_SHA}-linux-64bit/oc /usr/local/bin/ && \
    rm -rf /tmp/oc.tar.gz /tmp/openshift-origin-client-tools-${OC_VERSION}-${OC_TAG_SHA}-linux-64bit && \
    apk del \
    tar \
    gzip \
    && \
    rm -rf /var/cache/* /root/.cache/*
