FROM nixos/nix
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

VOLUME /datak

RUN set -x \
    && nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs \
    && nix-channel --update \
    && nix-build -A pythonFull '<nixpkgs>' \
    && nix-env -i cabal-install wget libevdev libevdevc ghc gmp libgcc automake cmake mmake libtool gnutar \
    && nix-env -i openssl ssl-cert-check ncurses autobuild bash curl git jq tmux vim watch net-tools \    
    && export CNODE_HOME=/opt/cardano/cnode \
    && mkdir -p $CNODE_HOME \
    #&& wget https://raw.githubusercontent.com/redoracle/jormungandr/haskell/prereqs.sh \
    #&& bash prereqs.sh \
    && echo "Install ghcup (The Haskell Toolchain installer) .." \
    && export BOOTSTRAP_HASKELL_NONINTERACTIVE=n \
    && curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh -s - -q \
    # shellcheck source=/dev/null
    && . ~/.ghcup/env \
    && ghcup install 8.6.5 \
    && ghcup set 8.6.5 \
    && ghc --version \
    && echo "Installing Cabal 3.0.0 .." \
    && wget https://downloads.haskell.org/cabal/cabal-install-3.0.0.0/cabal-install-3.0.0.0-x86_64-unknown-linux.tar.xz \
    && tar xf cabal-install-3.0.0.0-x86_64-unknown-linux.tar.xz \
    && chmod 755 cabal \
    && mkdir -p ~/.cabal/bin \
    && mv cabal ~/.ghcup/bin \
    && rm -f cabal-install-3.0.0.0-x86_64-unknown-linux.tar.xz cabal.sig \
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
    && cd ~/ \
    && CN=$(which cardano-node) \
    #&& echo "cardano-node run --config /datak/ptn/config/pbft_config.json --database-path /datak/ptn/db --host-addr `curl ifconfig.me` --signing-key /datak/configuration/002-Redoracle.key --delegation-certificate /datak/configuration/002-Redoracle.cert --port 9000 --socket-path /datak/ptn/data/pbft_node.socket --topology /datak/ptn/config/pbft_topology.json" > /entry-point \
    #&& chmod +x /entry-point \
    && nix-channel --remove nixpkgs \
    && rm -rf /nix/store/*-nixpkgs* \
    && nix-collect-garbage -d \
    && nix-store --verify --check-contents \
    && nix optimise-store \
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
