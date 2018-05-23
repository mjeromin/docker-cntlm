FROM alpine:3.7 as build

RUN set -x && \
    apk add --no-cache  \
    gcc \
    libc-dev \
    autoconf \
    automake \
    make

RUN set -x && \
    mkdir -p /tmp/build/cntlm-0.92.3/

ADD files/cntlm-0.92.3/ /tmp/build/cntlm-0.92.3/

RUN set -x && \
    cd /tmp/build/cntlm-0.92.3/ && \
    \
    CC="gcc" \
    \
    ./configure && \
    make && \
    make install

FROM alpine:3.7

LABEL maintainer="Mark Jeromin <mark.jeromin@sysfrog.net>"

RUN apk update \
  && apk add shadow

# Ensure users exist with desired uid/gid. If you bind mount a volume
# from the host or a data container, ensure you use the same uid.
# Override these values at build time using --buid-args.
ARG user=cntlm
ARG group=cntlm
ARG uid=3341
ARG gid=3341
RUN set -x && \
    groupadd -g ${gid} ${group} \
    && useradd -u ${uid} -g ${gid} -s /bin/false ${user}

ENV CNTLM_CONF /etc/cntlm.d/cntlm.conf

COPY --from=build /etc/cntlm.conf /usr/share/cntlm/cntlm.conf.build
COPY --from=build /usr/sbin/cntlm /usr/sbin/cntlm
COPY --from=build /usr/share/man/man1/cntlm.1 /usr/share/man/man1/cntlm.1
COPY files/etc/cntlm.conf /usr/share/cntlm/cntlm.conf.example
COPY scripts/start-cntlm.sh /usr/sbin/start-cntlm.sh
COPY scripts/loop-cntlm.sh /usr/sbin/loop-cntlm.sh

RUN set -x && \
    chmod 755 /usr/sbin/cntlm && \
    chmod 755 /usr/sbin/start-cntlm.sh && \
    mkdir -pm 775 /etc/cntlm.d && \
    chgrp ${group} /etc/cntlm.d && \
    chmod 644 /usr/share/man/man1/cntlm.1 && \
    chmod 644 /usr/share/cntlm/cntlm.conf.build && \
    chmod 644 /usr/share/cntlm/cntlm.conf.example

EXPOSE 8123/tcp

USER ${user}:${group}

CMD ["/usr/sbin/loop-cntlm.sh"]
