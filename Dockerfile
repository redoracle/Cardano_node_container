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
      org.label-schema.docker.cmd='docker run -dit redoracle/cardano-haskell-node' \
      org.label-schema.docker.cmd.devel='docker run --rm -ti redoracle/cardano-haskell-node' \
      org.label-schema.docker.debug='docker logs $CONTAINER' \
      io.github.offensive-security.docker.dockerfile="Dockerfile" \
      io.github.offensive-security.license="GPLv3" \
      MAINTAINER="RedOracle <info@redoracle.com>"

WORKDIR /root

VOLUME /datak

RUN set -x \
    && sed -i -e 's/^root::/root:*:/' /etc/shadow \
    && export CNODE_HOME=/opt/cardano/cnode \
    && apt-get -yqq update  \                                                       
    && apt-get -yqq dist-upgrade \
    && apt-get -yqq install curl g++ gcc gmp make ncurses xz-utils git jq pkg-config libsystemd-dev libz-dev libpq-dev libssl-dev libtinfo-dev tmux cmake vim watch net-tools geoip-bin geoip-database \    
    && curl -sSL https://get.haskellstack.org/ | sh \
    && install -d -m755 -o $(id -u) -g $(id -g) /nix \
    && groupadd -g 30000 --system nixbld \
    && useradd --home-dir /var/empty --gid 30000 --groups nixbld --no-user-group --system --shell /usr/sbin/nologin --uid $((30000 + 1)) --password "!" nixbld1 \
    && mkdir -p /root/.config/nix /root/.nixpkgs \
    && echo "{ allowUnfree = true; }" > /root/.nixpkgs/config.nix \
    && export NIX_PATH=nixpkgs=/root/.nix-defexpr/channels/nixpkgs:/root/.nix-defexpr/channels \
    && export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    && export PATH=/root/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.local/bin \
    && export SUDO_FORCE_REMOVE=yes \
    && curl https://nixos.org/nix/install | sh \
    && /root/.nix-profile/bin/nix-channel --update \
    && /root/.nix-profile/bin/nix-env -iA nixpkgs.nix \
    && /root/.nix-profile/bin/nix-env -i cabal-install \
    && curl -sSL https://get.haskellstack.org/ | sh \
    && wget https://raw.githubusercontent.com/redoracle/guild-operators/master/files/ptn0/scripts/prereqs.sh \
    && bash prereqs.sh \
    && git clone https://github.com/input-output-hk/cardano-wallet.git \
    && cd cardano-wallet \
    && stack build --test --no-run-tests  \
    && stack install \
    && git clone https://github.com/input-output-hk/cardano-node.git \
    && cd cardano-node \
    && $CNODE_HOME/scripts/cabal-build-all.sh \
    && cabal install \
    && . ~/.profile \
    && git clone https://github.com/cardano-community/guild-operators.git \
    && mkdir -p /datak/ptn/{config,data,db} \
    && cd ~/ \
    && CN=$(which cardano-node) \
    #&& echo "cardano-node run --config /datak/ptn/config/pbft_config.json --database-path /datak/ptn/db --host-addr `curl ifconfig.me` --signing-key /datak/configuration/002-Redoracle.key --delegation-certificate /datak/configuration/002-Redoracle.cert --port 9000 --socket-path /datak/ptn/data/pbft_node.socket --topology /datak/ptn/config/pbft_topology.json" > /entry-point \
    #&& chmod +x /entry-point \
    && apt-get clean   \
    && apt autoremove --purge -y \
    && rm -rf /var/lib/apt/lists/* \
    && /root/.nix-profile/bin/nix-channel --remove nixpkgs \
    && rm -rf /nix/store/*-nixpkgs* \
    && /root/.nix-profile/bin/nix-collect-garbage -d \
    && /root/.nix-profile/bin/nix-store --verify --check-contents \
    && /root/.nix-profile/bin/nix optimise-store \
    && rm -rf /tmp/* /var/tmp/*    

ENV \
DEBIAN_FRONTEND=noninteractive \
LANG=C.UTF-8 \
ENV=/etc/profile \
USER=root \
NIX_PATH=nixpkgs=/root/.nix-defexpr/channels/nixpkgs:/root/.nix-defexpr/channels \
NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
SUDO_FORCE_REMOVE=yes \
PATH=/root/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.local/bin


EXPOSE 9000 3000 3101 3001
#CMD ["/bin/bash", "~/jormungandr/tools/start-node.sh &"]
#ENTRYPOINT  ["/entry-point"]
