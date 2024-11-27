FROM alpine:latest

ENV EV_EXTRA_DEFS=-DEV_NO_ATFORK
ENV LIBEV_FLAGS=4
ENV LANG=en_US.utf-8
ENV LANGUAGE=en_US.utf-8
ENV LC_ALL=en_US.utf-8
ENV TZ=America/New_York
ENV PERL_CPANM_OPT="--no-man-pages --notest --mirror https://cpan.metacpan.org --mirror https://mirrors.rit.edu/CPAN --verify"

COPY cpanfile /
ENV MOJO_HOME=/app
COPY ./app $MOJO_HOME
ENV MOJO_LOG_LEVEL=info
ENV MOJO_MODE=development
ENV PERL5LIB=$MOJO_HOME/lib
ENV PATH=$MOJO_HOME/bin:$PATH
ENV WATCH_ITERATION=2

RUN set -x \
    && apk update \
    && apk add --no-cache --update tzdata perl perl-io-socket-ssl perl-dbd-pg perl-dev g++ make wget curl \
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/America/New_York /etc/localtime \
    && echo "America/New_York" > /etc/timezone \
    && curl -sL https://cpanmin.us | perl - App::cpanminus \
    && env -u MOJO_HOME cpanm --installdeps . \
    && apk del g++ make \
    && rm -rf /var/cache/apk/* /root/.cpanm/* /usr/local/share/man/* \
    && chgrp -R 0 $MOJO_HOME \
    && chmod -R g=u $MOJO_HOME \
    && date \
    && mojo version

WORKDIR $MOJO_HOME
ENV KUBECONFIG=/root/.kube/config