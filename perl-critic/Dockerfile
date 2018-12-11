FROM alpine:latest
RUN set -x; \
    apk add --no-cache \
    perl-dev \
    g++ \
    make \
    perl-clone \
    perl-perlio-utf8_strict \
    perl-app-cpanminus \
    perl-io-socket-ssl \
    && \
    cpanm --quiet --no-wget --notest --no-man-pages --from https://cpan.metacpan.org/ \
    Perl::Critic \
    && \
    apk del perl-dev g++ make && \
    rm -rf /root/.cpanm/* /usr/local/share/man/*
COPY .perlcriticrc /etc/
COPY .perltidyrc /etc/
ENV PERLCRITIC /etc/.perlcriticrc
ENV PERLTIDY /etc/.perltidyrc
