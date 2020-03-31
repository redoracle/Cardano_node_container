FROM debian:stable
MAINTAINER RedOracle

ARG BUILD_DATE
ARG VERSION
ARG VCS_URL
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.name='Cardano Node by Redoracle' \
      org.label-schema.description='UNOfficial Cardano Haskell Node docker image' \
      org.label-schema.usage='https://www.redoracle.com/docker/' \
      org.label-schema.url='https://www.redoracle.com/' \
      org.label-schema.vendor='Red0racle S3curity' \
      org.label-schema.schema-version='1.0' \
      org.label-schema.docker.cmd='docker run -dit redoracle/cardano-node-docker' \
      org.label-schema.docker.cmd.devel='docker run --rm -ti redoracle/cardano-node-docker' \
      org.label-schema.docker.debug='docker logs $CONTAINER' \
      io.github.offensive-security.docker.dockerfile="Dockerfile" \
      io.github.offensive-security.license="GPLv3" \
      MAINTAINER="RedOracle <info@redoracle.com>"

WORKDIR /root

VOLUME /datak

RUN set -x \
    && sed -i -e 's/^root::/root:*:/' /etc/shadow \
    && apt-get -yqq update \                                                       
    && apt-get -yqq dist-upgrade \
    && apt-get -yqq install curl git jq pkg-config libsystemd-dev libz-dev libpq-dev libssl-dev libtinfo-dev vim watch net-tools geoip-bin geoip-database \    
    && curl -sSL https://get.haskellstack.org/ | sh \
    && install -d -m755 -o $(id -u) -g $(id -g) /nix \
    && curl https://nixos.org/nix/install | sh \
    && export PATH=$PATH:/root/.local/bin \
    # https://github.com/input-output-hk/cardano-explorer/blob/master/doc/building-running.md \
    && git clone https://github.com/input-output-hk/cardano-byron-proxy \
    && git clone https://github.com/input-output-hk/cardano-explorer \
    && git clone https://github.com/input-output-hk/cardano-node.git \
    && cd cardano-node/ && stack build && stack install && . ~/.profile \
    && git clone https://github.com/cardano-community/guild-operators.git \
    && mkdir -p /datak/ptn/{config,data,db} \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

ENV \
DEBIAN_FRONTEND noninteractive \
LANG C.UTF-8 \
ENV=/etc/profile \
USER=root \
PATH=/root/jormungandr/:/root/jormungandr/scripts:/root/jormungandr/tools:/bin:/sbin:/usr/bin:/usr/sbin:/root/.local/bin:$PATH 


EXPOSE 9000 3000 3101
#CMD ["/bin/bash", "~/jormungandr/tools/start-node.sh &"]
