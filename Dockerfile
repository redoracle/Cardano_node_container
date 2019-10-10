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
      org.label-schema.description='UNOfficial Cardano Node docker image' \
      org.label-schema.usage='https://www.redoracle.com/docker/' \
      org.label-schema.url='https://www.redoracle.com/' \
      org.label-schema.vendor='Red0racle S3curity' \
      org.label-schema.schema-version='1.0' \
      org.label-schema.docker.cmd='docker run --rm redoracle/cardano-node-docker' \
      org.label-schema.docker.cmd.devel='docker run --rm -ti redoracle/cardano-node-docker' \
      org.label-schema.docker.debug='docker logs $CONTAINER' \
      io.github.offensive-security.docker.dockerfile="Dockerfile" \
      io.github.offensive-security.license="GPLv3" \
      MAINTAINER="RedOracle <info@redoracle.com>"

VOLUME /datak

RUN set -x \
    && sed -i -e 's/^root::/root:*:/' /etc/shadow \
    && apt-get -yqq update \                                                       
    && apt-get -yqq dist-upgrade \
    && apt-get -yqq install curl wget bash build-essential libssl-dev tmux cmake g++ pkg-config git vim-common libwebsockets-dev libjson-c-dev npm watch jq watch net-tools geoip-bin geoip-database && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \   
    && mkdir -p /root/red-jor-test \
    && mkdir -p /root/red-jor-test/script \   
    && cd /root/red-jor-test \
    && wget https://raw.githubusercontent.com/clio-one/cardano-on-the-rocks/master/scripts/Jormungandr/jtools.sh \
    && sed -i -e 's/8080/3101/' jtools.sh \
    && sed -i -e 's/^BASE_FOLDER=~\/jormungandr\//BASE_FOLDER=~\/red-jor-test\//' jtools.sh \
    && sed -i -e 's/^WALLET_FOLDER=\$BASE_FOLDER\"wallet\\"/WALLET_FOLDER=\/datak\/wallet\//' jtools.sh \
    && sed -i -e 's/^POOL_FOLDER=\$BASE_FOLDER\"pool\\"/POOL_FOLDER=\/datak\/pool\//' jtools.sh \
    && sed -i -e 's/^JTOOLS_LOG=\${BASE_FOLDER}\/jtools-history.log/JTOOLS_LOG=\/datak\/jtools-history.log/' jtools.sh \
    && cd /tmp/ \
    && git clone https://github.com/tsl0922/ttyd.git \
    && cd ttyd && mkdir build && cd build \
    && cmake .. \
    && make && make install \
    && echo "ttyd -p 9001 -R tmux new -A -s ttyd tmux" > ~/red-jor-test/script/web_interface_tmux.sh \
    && cd ~/red-jor-test/ \
    && echo "/root/red-jor-test/jcli rest v0 node stats get --host \"http://127.0.0.1:3101/api\"" > ~/red-jor-test/script/jstats.sh \
    && echo "/root/red-jor-test/jcli rest v0 utxo get --host \"http://127.0.0.1:3101/api\"" > ~/red-jor-test/script/jstatx.sh \
    && echo "/root/red-jor-test/jcli rest v0 shutdown get --host \"http://127.0.0.1:3101/api\"" > ~/red-jor-test/script/jshutdown.sh \
    && echo "until RUST_BACKTRACE=FULL /root/red-jor-test/jormungandr --config /datak/node-config.yaml --genesis-block-hash adbdd5ede31637f6c9bad5c271eec0bc3d0cb9efb86a5b913bb55cba549d0770 do; echo \"Jormungandr crashed with exit code $?.  Respawning..\" >&2; sleep 1; done" > ~/red-jor-test/script/start-node.sh \
    && echo "until RUST_BACKTRACE=FULL /root/red-jor-test/jormungandr --config /datak/node-config.yaml --secret /datak/pool/ZiaAda/secret.yaml --genesis-block-hash adbdd5ede31637f6c9bad5c271eec0bc3d0cb9efb86a5b913bb55cba549d0770; do echo \"Jormungandr crashed with exit code $?.  Respawning..\" >&2; sleep 1; done" > ~/red-jor-test/script/start-pool.sh \
    && echo "watch \"netstat -anl  | grep tcp | grep EST |  awk '{print $ 5}' | cut -d ':' -f 1 | sort | uniq | xargs -n 1 geoiplookup {} | sed -r 's/^GeoIP Country Edition://g'\"" > ~/red-jor-test/script/watch_node.sh \
    && chmod +x ~/red-jor-test/script/*.sh \
    && chmod +x ~/red-jor-test/*.sh \
    && ln -s ~/red-jor-test/jtools.sh /usr/local/bin/jtools \
    && ln -s ~/red-jor-test/script/jstats.sh /usr/local/bin/jstats \
    && ln -s ~/red-jor-test/script/jstatx.sh /usr/local/bin/jstatx \
    && ln -s ~/red-jor-test/script/jshutdown.sh /usr/local/bin/jshutdown \
    && ln -s ~/red-jor-test/script/jshutdown.sh /usr/local/bin/stop-node \
    && ln -s ~/red-jor-test/script/start-node.sh /usr/local/bin/start-node \
    && ln -s ~/red-jor-test/script/start-pool.sh /usr/local/bin/start-pool \
    && ln -s ~/red-jor-test/script/watch_node.sh /usr/local/bin/watch_node \
    && wget https://github.com/input-output-hk/jormungandr/releases/download/v0.5.5/jormungandr-v0.5.5-x86_64-unknown-linux-gnu.tar.gz \
    && tar xzvf jormungandr-v0.5.5-x86_64-unknown-linux-gnu.tar.gz \
    && rm jormungandr-v0.5.5-x86_64-unknown-linux-gnu.tar.gz \                
    && curl https://sh.rustup.rs -sSf > rustup_inst.sh \        
    && sh rustup_inst.sh -y \
    && . $HOME/.cargo/env \
    && rustup install stable \
    && curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf > wasm.sh \
    && sh wasm.sh \
    && rm rustup_inst.sh wasm.sh \
    && git clone https://github.com/input-output-hk/js-chain-libs.git \
    && cd js-chain-libs \
    && git submodule init \
    && git submodule update \
    && wasm-pack build \
    && wasm-pack pack \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  \
    
ENV \
DEBIAN_FRONTEND noninteractive \
ENV=/etc/profile \
USER=root \
PATH=/root/red-jor-test/:/root/red-jor-test/script:/bin:/sbin:/usr/bin:/usr/sbin:$PATH 

    # Faucet examples \
    # https://github.com/input-output-hk/js-chain-libs/tree/master/examples/faucet \
    # https://github.com/input-output-hk/js-chain-libs \
    # https://github.com/input-output-hk/shelley-testnet/wiki/JavaScript-SDK:---How-to-install-the-example-faucet-app%3F \
    # Very important https://github.com/input-output-hk/shelley-testnet/wiki/How-to-setup-a-Jormungandr-Networking--node-(--v0.5.0) \
    
CMD ["bash"]

EXPOSE 9001 8299 3100 3000 3101
